from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATE_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}$")
POST_NAME_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}-[a-z0-9-]+\.md$")
IMAGE_PATTERN = re.compile(r"!\[[^\]]*]\((/assets/images/[^)\s]+)\)")
LIQUID_LINK_PATTERN = re.compile(r"{%\s*link\s+([^%\s]+)\s*%}")
CJK_PATTERN = re.compile(r"[\u3400-\u9fff]")

# A Chinese sentence carries the same meaning in far fewer characters than the
# English equivalent, so descriptions are measured against a lower minimum.
MIN_DESCRIPTION_LENGTH = 30
MIN_CJK_DESCRIPTION_LENGTH = 12

CATEGORIES = {
    "Windows & Networking": ROOT / "docs" / "general",
    "Browsers & WebView2": ROOT / "docs" / "Browsers",
    "IIS & Web Hosting": ROOT / "docs" / "IIS",
    ".NET & Cloud Diagnostics": ROOT / "docs" / "dotnet",
}

TOP_LEVEL_PAGES = [
    ROOT / "index.md",
    ROOT / "blog" / "index.md",
    ROOT / "guides" / "index.md",
    ROOT / "about.md",
    ROOT / "disclaimer.md",
]

# Chinese guides mirror the English tree inside the docs_zh collection. Just the
# Docs resolves `parent` only within a collection, so the translated titles form
# an independent navigation namespace.
ZH_ROOT = ROOT / "_docs_zh"
ZH_GUIDES_TITLE = "指南"
ZH_CATEGORIES = {
    "Windows 与网络": ZH_ROOT / "general",
    "浏览器与 WebView2": ZH_ROOT / "Browsers",
    "IIS 与 Web 托管": ZH_ROOT / "IIS",
    ".NET 与云诊断": ZH_ROOT / "dotnet",
}


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def parse_front_matter(path: Path, errors: list[str]) -> tuple[dict[str, str], str]:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()

    if not lines or lines[0] != "---":
        errors.append(f"{relative(path)}: missing opening front matter delimiter")
        return {}, text

    try:
        end = lines.index("---", 1)
    except ValueError:
        errors.append(f"{relative(path)}: missing closing front matter delimiter")
        return {}, text

    fields: dict[str, str] = {}
    for line in lines[1:end]:
        match = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if match:
            fields[match.group(1)] = match.group(2).strip().strip("\"'")

    return fields, text


def require_fields(path: Path, fields: dict[str, str], names: list[str], errors: list[str]) -> None:
    for name in names:
        if not fields.get(name):
            errors.append(f"{relative(path)}: missing required '{name}' value")


def parse_nav_order(path: Path, fields: dict[str, str], errors: list[str]) -> int | None:
    value = fields.get("nav_order", "")
    try:
        return int(value)
    except ValueError:
        errors.append(f"{relative(path)}: nav_order must be an integer")
        return None


def validate_metadata(path: Path, fields: dict[str, str], errors: list[str]) -> None:
    description = fields.get("description", "")
    minimum = (
        MIN_CJK_DESCRIPTION_LENGTH
        if CJK_PATTERN.search(description)
        else MIN_DESCRIPTION_LENGTH
    )
    if description and len(description) < minimum:
        errors.append(f"{relative(path)}: description should be at least {minimum} characters")

    tags = fields.get("tags", "")
    if tags and not re.fullmatch(r"\[[^\]]+\]", tags):
        errors.append(f"{relative(path)}: tags must use a non-empty inline YAML list")

    modified = fields.get("last_modified_date")
    if modified and not DATE_PATTERN.fullmatch(modified):
        errors.append(f"{relative(path)}: last_modified_date must use YYYY-MM-DD")

    verified = fields.get("last_verified_date")
    if verified and not DATE_PATTERN.fullmatch(verified):
        errors.append(f"{relative(path)}: last_verified_date must use YYYY-MM-DD")

    # last_verified_date states that the procedure was exercised in a specific
    # environment, so tested_on must describe that environment.
    tested_on = fields.get("tested_on")
    if verified and not tested_on:
        errors.append(f"{relative(path)}: last_verified_date requires a 'tested_on' value")
    if tested_on and not verified:
        errors.append(f"{relative(path)}: tested_on requires a 'last_verified_date' value")


def path_exists_with_exact_case(relative_path: str) -> bool:
    current = ROOT
    for part in Path(relative_path).parts:
        if not current.is_dir():
            return False
        names = {entry.name for entry in current.iterdir()}
        if part not in names:
            return False
        current /= part
    return current.exists()


def validate_local_references(paths: list[Path], errors: list[str]) -> None:
    for path in paths:
        text = path.read_text(encoding="utf-8")

        for image in IMAGE_PATTERN.findall(text):
            target = image.lstrip("/")
            if not path_exists_with_exact_case(target):
                errors.append(f"{relative(path)}: missing image '{image}'")

        for target in LIQUID_LINK_PATTERN.findall(text):
            if not path_exists_with_exact_case(target):
                errors.append(f"{relative(path)}: missing Liquid link target '{target}'")


def validate_guides(errors: list[str]) -> list[Path]:
    guide_paths: list[Path] = []
    child_orders: dict[str, dict[int, list[str]]] = defaultdict(lambda: defaultdict(list))
    category_orders: dict[int, list[str]] = defaultdict(list)

    for parent, directory in CATEGORIES.items():
        index_path = directory / "index.md"
        fields, _ = parse_front_matter(index_path, errors)
        require_fields(
            index_path,
            fields,
            ["title", "parent", "nav_order", "description", "tags", "last_modified_date", "has_children"],
            errors,
        )
        validate_metadata(index_path, fields, errors)

        if fields.get("title") != parent:
            errors.append(f"{relative(index_path)}: title must be '{parent}'")
        if fields.get("parent") != "Guides":
            errors.append(f"{relative(index_path)}: parent must be 'Guides'")
        if fields.get("has_children") != "true":
            errors.append(f"{relative(index_path)}: has_children must be true")

        order = parse_nav_order(index_path, fields, errors)
        if order is not None:
            category_orders[order].append(relative(index_path))
        guide_paths.append(index_path)

        for path in sorted(directory.glob("*.md")):
            if path.name == "index.md":
                continue

            fields, _ = parse_front_matter(path, errors)
            require_fields(
                path,
                fields,
                [
                    "title",
                    "parent",
                    "grand_parent",
                    "nav_order",
                    "description",
                    "tags",
                    "last_modified_date",
                ],
                errors,
            )
            validate_metadata(path, fields, errors)

            if fields.get("parent") != parent:
                errors.append(f"{relative(path)}: parent must be '{parent}'")
            if fields.get("grand_parent") != "Guides":
                errors.append(f"{relative(path)}: grand_parent must be 'Guides'")

            order = parse_nav_order(path, fields, errors)
            if order is not None:
                child_orders[parent][order].append(relative(path))
            guide_paths.append(path)

    for order, paths in category_orders.items():
        if len(paths) > 1:
            errors.append(f"Guides: duplicate category nav_order {order}: {', '.join(paths)}")

    for parent, orders in child_orders.items():
        for order, paths in orders.items():
            if len(paths) > 1:
                errors.append(f"{parent}: duplicate nav_order {order}: {', '.join(paths)}")

    return guide_paths


def english_counterpart(path: Path) -> Path:
    """Map a Chinese collection file to the English page it translates."""
    parts = path.relative_to(ZH_ROOT).parts
    if parts == ("index.md",):
        return ROOT / "guides" / "index.md"
    return ROOT / "docs" / Path(*parts)


def expected_zh_permalink(path: Path) -> str:
    """The URL a Chinese page must publish at.

    The language switcher pairs a page with its counterpart by prefixing the
    English URL with /zh, so a wrong permalink silently breaks the switch.
    """
    parts = path.relative_to(ZH_ROOT).parts
    if parts == ("index.md",):
        return "/zh/guides/"

    directory = "/".join(parts[:-1])
    if parts[-1] == "index.md":
        return f"/zh/docs/{directory}/"
    return f"/zh/docs/{directory}/{Path(parts[-1]).stem}/"


def validate_zh_guides(errors: list[str]) -> list[Path]:
    if not ZH_ROOT.exists():
        return []

    zh_paths: list[Path] = []
    child_orders: dict[str, dict[int, list[str]]] = defaultdict(lambda: defaultdict(list))
    category_orders: dict[int, list[str]] = defaultdict(list)

    def check_shared_rules(path: Path, fields: dict[str, str]) -> None:
        permalink = fields.get("permalink", "")
        expected = expected_zh_permalink(path)
        if permalink != expected:
            errors.append(f"{relative(path)}: permalink must be '{expected}'")

        counterpart = english_counterpart(path)
        if not counterpart.exists():
            errors.append(
                f"{relative(path)}: translates '{relative(counterpart)}', which does not exist"
            )

    root_index = ZH_ROOT / "index.md"
    fields, _ = parse_front_matter(root_index, errors)
    require_fields(
        root_index,
        fields,
        ["title", "permalink", "nav_order", "description", "tags", "last_modified_date", "has_children"],
        errors,
    )
    validate_metadata(root_index, fields, errors)
    check_shared_rules(root_index, fields)
    if fields.get("title") != ZH_GUIDES_TITLE:
        errors.append(f"{relative(root_index)}: title must be '{ZH_GUIDES_TITLE}'")
    if fields.get("has_children") != "true":
        errors.append(f"{relative(root_index)}: has_children must be true")
    zh_paths.append(root_index)

    for parent, directory in ZH_CATEGORIES.items():
        index_path = directory / "index.md"
        if not index_path.exists():
            errors.append(f"{relative(index_path)}: missing category index for '{parent}'")
            continue

        fields, _ = parse_front_matter(index_path, errors)
        require_fields(
            index_path,
            fields,
            [
                "title",
                "permalink",
                "parent",
                "nav_order",
                "description",
                "tags",
                "last_modified_date",
                "has_children",
            ],
            errors,
        )
        validate_metadata(index_path, fields, errors)
        check_shared_rules(index_path, fields)

        if fields.get("title") != parent:
            errors.append(f"{relative(index_path)}: title must be '{parent}'")
        if fields.get("parent") != ZH_GUIDES_TITLE:
            errors.append(f"{relative(index_path)}: parent must be '{ZH_GUIDES_TITLE}'")
        if fields.get("has_children") != "true":
            errors.append(f"{relative(index_path)}: has_children must be true")

        order = parse_nav_order(index_path, fields, errors)
        if order is not None:
            category_orders[order].append(relative(index_path))
        zh_paths.append(index_path)

        for path in sorted(directory.glob("*.md")):
            if path.name == "index.md":
                continue

            fields, _ = parse_front_matter(path, errors)
            require_fields(
                path,
                fields,
                [
                    "title",
                    "permalink",
                    "parent",
                    "grand_parent",
                    "nav_order",
                    "description",
                    "tags",
                    "last_modified_date",
                ],
                errors,
            )
            validate_metadata(path, fields, errors)
            check_shared_rules(path, fields)

            if fields.get("parent") != parent:
                errors.append(f"{relative(path)}: parent must be '{parent}'")
            if fields.get("grand_parent") != ZH_GUIDES_TITLE:
                errors.append(f"{relative(path)}: grand_parent must be '{ZH_GUIDES_TITLE}'")

            order = parse_nav_order(path, fields, errors)
            if order is not None:
                child_orders[parent][order].append(relative(path))
            zh_paths.append(path)

    unexpected = {
        path
        for path in ZH_ROOT.rglob("*.md")
        if path.parent != ZH_ROOT and path.parent not in ZH_CATEGORIES.values()
    }
    for path in sorted(unexpected):
        errors.append(f"{relative(path)}: not inside a known Chinese guide category")

    for order, paths in category_orders.items():
        if len(paths) > 1:
            errors.append(f"{ZH_GUIDES_TITLE}: duplicate category nav_order {order}: {', '.join(paths)}")

    for parent, orders in child_orders.items():
        for order, paths in orders.items():
            if len(paths) > 1:
                errors.append(f"{parent}: duplicate nav_order {order}: {', '.join(paths)}")

    return zh_paths


def validate_top_level_pages(errors: list[str]) -> list[Path]:
    orders: dict[int, list[str]] = defaultdict(list)

    for path in TOP_LEVEL_PAGES:
        fields, _ = parse_front_matter(path, errors)
        require_fields(path, fields, ["title", "nav_order", "description"], errors)
        validate_metadata(path, fields, errors)

        order = parse_nav_order(path, fields, errors)
        if order is not None:
            orders[order].append(relative(path))

    for order, paths in orders.items():
        if len(paths) > 1:
            errors.append(f"Top-level navigation: duplicate nav_order {order}: {', '.join(paths)}")

    return TOP_LEVEL_PAGES


def validate_posts(errors: list[str]) -> list[Path]:
    posts_directory = ROOT / "_posts"
    if not posts_directory.exists():
        return []

    posts = sorted(posts_directory.glob("*.md"))
    for path in posts:
        if not POST_NAME_PATTERN.fullmatch(path.name):
            errors.append(f"{relative(path)}: post filename must use YYYY-MM-DD-lowercase-title.md")

        fields, text = parse_front_matter(path, errors)
        require_fields(path, fields, ["title", "date", "description", "tags"], errors)
        validate_metadata(path, fields, errors)
        if "<!--more-->" not in text:
            errors.append(f"{relative(path)}: missing <!--more--> excerpt separator")

    return posts


def main() -> int:
    errors: list[str] = []
    site_paths = validate_guides(errors)
    site_paths.extend(validate_zh_guides(errors))
    site_paths.extend(validate_top_level_pages(errors))
    site_paths.extend(validate_posts(errors))
    validate_local_references(site_paths, errors)

    if errors:
        print("Content validation failed:")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"Validated {len(site_paths)} site content files.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
