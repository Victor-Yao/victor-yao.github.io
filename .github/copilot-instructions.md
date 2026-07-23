# Copilot instructions

## Repository purpose and architecture

- This repository is a troubleshooting knowledge base published through GitHub Pages. It uses Jekyll 4.4.1 with the Just the Docs 0.12.0 theme.
- `index.md` is the site landing page. It links to each top-level documentation category with Jekyll `{% link ... %}` tags.
- Content lives under `docs/<category>/`. Each category has an `index.md` parent page, and the other Markdown files are its Just the Docs child pages.
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

# Preview locally with automatic rebuilds.
bundle exec jekyll serve --livereload
```

The generated `_site/` directory and Jekyll/Bundler caches are ignored and must not be committed.
For UI-affecting changes, start the local preview and use Playwright MCP against `http://127.0.0.1:4000` to check navigation, images, callouts, and automatic light/dark theme behavior.

## Documentation and navigation conventions

- Preserve the existing category directory casing: `docs/Browsers`, `docs/IIS`, `docs/dotnet`, and `docs/general`. Local Windows paths are case-insensitive, but the GitHub Pages build runs on Linux.
- Every child page uses this front matter shape:

  ```yaml
  ---
  title: Page Title
  parent: Browsers
  nav_order: 24
  last_modified_date: 2026-07-23
  ---
  ```

- `parent` must exactly match the category index `title` (`Browsers`, `IIS`, `.NET`, or `General`).
- Keep `nav_order` unique within a parent. Existing child-page orders are contiguous, so inspect siblings and use the next or intentionally repositioned integer.
- Update `last_modified_date` in `YYYY-MM-DD` format whenever a page changes.
- Category `index.md` files have no `parent`; they set `has_children: true`. When adding or renaming a top-level category, also update the manually maintained links in the root `index.md`.
- Start document content at `##`; the page title comes from front matter. Guides favor concise numbered procedures, copy/paste-ready commands, and language-tagged fenced code blocks.
- Use Jekyll links for repository pages, for example `{% link docs/Browsers/index.md %}`.
- Reference images from the site root, for example `![Descriptive alt text](/assets/images/example.png)`, and add the corresponding file under `assets/images/`.
- Just the Docs callouts are configured only for `note`, `tip`, `warning`, and `important`. Use:

  ```markdown
  {: .warning }
  > Warning text.
  ```

- `Templates/new doc.md` is a starter only and is excluded from the rendered site. Publish new content under the appropriate `docs/` category.

## Site-wide changes

- Keep dependency versions in `Gemfile` and `Gemfile.lock` aligned; Dependabot manages direct Bundler dependencies and GitHub Actions updates.
- Changes to `_config.yml` affect every page. Preserve the configured default layout, callout names, search, edit links, and `baseurl` behavior unless the task explicitly changes site-wide behavior.
- When editing `_includes/nav_footer_custom.html`, retain both modern `MediaQueryList.addEventListener` handling and the `addListener` fallback used for older browsers.
- Validate documentation, front matter, Liquid links, and theme changes with `bundle exec jekyll build` before finishing.
