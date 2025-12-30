# Troubleshooting KB

This repo is my little troubleshooting knowledge base — quick steps, commands, and checklists I use when debugging stuff.

It’s published as a GitHub Pages site using the **Just the Docs** theme.

## What you’ll find here
- Practical “do this, then that” guides
- Copy/paste-ready commands
- Notes I want to be able to find again later 😄

## Main sections
- Microsoft Edge
- IIS
- ASP.NET
- .NET
- Edge WebView2

(And more over time.)

## Adding a new doc
1. Create a new Markdown file under `docs/<category>/`
   - Example: `docs/edge/capturesomething.md`
2. Add a small front matter header at the top:
   ```md
   ---
   title: Fix download errors
   parent: Edge
   ---
