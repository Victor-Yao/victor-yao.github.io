# Copilot instructions

## Repository purpose and architecture

- This repository is a personal technical site published through GitHub Pages. It uses Jekyll 4.4.1 with the Just the Docs 0.12.0 theme.
- `index.md` is the site landing page. The two main content entry points are `blog/index.md` for chronological articles and `guides/index.md` for evergreen troubleshooting content.
- Blog articles use Jekyll posts under `_posts/`. Guides live under `docs/<category>/`; each category is nested under the `Guides` parent page.
- `_config.yml` controls the theme, search, callout types, default layout, edit links, and footer timestamps.
- `_includes/nav_footer_custom.html` is the only custom theme behavior. It follows the operating system light/dark preference through `jtd.setTheme`.
- Screenshots and other document images live in `assets/images/`. Supporting troubleshooting scripts live in `assets/Scripts/` and should stay synchronized with the guides that reference them.
- `.github/workflows/ci.yml` runs a Jekyll build for every pull request and every push to `main`. `.github/workflows/pages.yml` performs the production build and deploys `main` to GitHub Pages.

## Build and preview

Use Ruby 3.3 and Bundler 2.5.9, matching GitHub Actions and `Gemfile.lock`. Run commands from the repository root.

```bash
# Restore the versions recorded in Gemfile.lock.
bundle install

# Build exactly as the CI validation job does.
bundle exec jekyll build

# Validate front matter, navigation ordering, images, and Liquid links.
python scripts/validate_content.py

# Preview locally with automatic rebuilds.
bundle exec jekyll serve --livereload
```

The generated `_site/` directory and Jekyll/Bundler caches are ignored and must not be committed.
For UI-affecting changes, start the local preview and use Playwright MCP against `http://127.0.0.1:4000` to check navigation, images, callouts, and automatic light/dark theme behavior.

## Documentation and navigation conventions

- Preserve the existing category directory casing: `docs/Browsers`, `docs/IIS`, `docs/dotnet`, and `docs/general`. Local Windows paths are case-insensitive, but the GitHub Pages build runs on Linux.
- Every guide page uses this front matter shape:

  ```yaml
  ---
  title: Page Title
  parent: Browsers & WebView2
  grand_parent: Guides
  nav_order: 24
  description: One concise sentence describing the guide.
  tags: [edge, policy]
  last_modified_date: 2026-07-23
  last_verified_date: 2026-07-23
  tested_on: Windows 11 and Microsoft Edge Stable
  ---
  ```

- `parent` must exactly match the category index `title` (`Windows & Networking`, `Browsers & WebView2`, `IIS & Web Hosting`, or `.NET & Cloud Diagnostics`).
- All guide pages use `grand_parent: Guides`. Category `index.md` files use `parent: Guides` and `has_children: true`.
- Keep `nav_order` unique within a parent. Existing child-page orders are contiguous, so inspect siblings and use the next or intentionally repositioned integer.
- Update `last_modified_date` in `YYYY-MM-DD` format whenever a page changes.
- Set `last_verified_date` and `tested_on` only after actually exercising the documented procedure in that environment.
- Blog posts use `_posts/YYYY-MM-DD-lowercase-title.md`, require `date`, `description`, and `tags`, and use the `<!--more-->` separator after the introductory excerpt. Posts are listed on `blog/index.md` and excluded from the sidebar.
- When adding or renaming a guide category, update both `guides/index.md` and the manually maintained guide links in the root `index.md`.
- Start document content at `##`; the page title comes from front matter. Guides favor concise numbered procedures, copy/paste-ready commands, and language-tagged fenced code blocks.
- Use Jekyll links for repository pages, for example `{% link docs/Browsers/index.md %}`.
- Reference images from the site root, for example `![Descriptive alt text](/assets/images/example.png)`, and add the corresponding file under `assets/images/`.
- Just the Docs callouts are configured only for `note`, `tip`, `warning`, and `important`. Use:

  ```markdown
  {: .warning }
  > Warning text.
  ```

- `Templates/new doc.md` and `Templates/new post.md` are starters only and are excluded from the rendered site. Publish guides under `docs/` and articles under `_posts/`.

## Site-wide changes

- Keep dependency versions in `Gemfile` and `Gemfile.lock` aligned; Dependabot manages direct Bundler dependencies and GitHub Actions updates.
- Changes to `_config.yml` affect every page. Preserve the configured default layout, callout names, search, edit links, and `baseurl` behavior unless the task explicitly changes site-wide behavior.
- When editing `_includes/nav_footer_custom.html`, retain both modern `MediaQueryList.addEventListener` handling and the `addListener` fallback used for older browsers.
- Run `python scripts/validate_content.py` and `bundle exec jekyll build` before finishing content or site-wide changes.
