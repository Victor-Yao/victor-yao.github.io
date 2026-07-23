# Victor Yao's Tech Notes

This repository contains the source for a personal technical site focused on practical troubleshooting guides, diagnostic techniques, and deeper engineering notes.

The site is published through GitHub Pages using Jekyll and the **Just the Docs** theme.

## Content

- Repeatable procedures for collecting diagnostic data.
- Copy/paste-ready commands and supporting scripts.
- Technical explanations and lessons learned from real-world debugging.
- Browser, Windows, IIS, and .NET troubleshooting guidance.

The published site separates chronological articles under **Blog** from evergreen task-focused content under **Guides**.

## Local development

Use Ruby 3.3 and the Bundler version recorded in `Gemfile.lock`.

```bash
bundle install
bundle exec jekyll serve --livereload
```

Open `http://127.0.0.1:4000` to preview the site. Run `bundle exec jekyll build` before committing site-wide changes.

## Adding a guide

1. Create a Markdown file under the existing category with the exact directory casing, for example `docs/Browsers/capture-something.md`.
2. Start from `Templates/new doc.md`.
3. Set `parent`, `grand_parent: Guides`, a unique `nav_order` within that category, and `last_modified_date`.
4. Put screenshots in `assets/images/` and reference them with root-relative URLs.

## Adding a blog post

1. Copy `Templates/new post.md` to `_posts/YYYY-MM-DD-lowercase-title.md`.
2. Set a publication `date`, a concise `description`, and relevant `tags`.
3. Keep `<!--more-->` after the introductory excerpt used by the Blog index.
4. Use primary or official references for technical claims where possible.

## Usage and license

The site includes a public [disclaimer and data privacy guide](disclaimer.md) for diagnostic artifacts and potentially destructive procedures.

The repository is licensed under the [MIT License](LICENSE).
