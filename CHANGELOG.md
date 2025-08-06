## [Unreleased]

## [0.6.0]

- Fix indexing for search url-less menu items
- Support for Algolia

## [0.5.0]

- Wrap styles in CSS layers to make it easier to override
- Reset styles by wrapping them in `.reset` rather than using `revert-layer` which cause side-effects
- Use `<div>` for user content rather than `<article>` because [on webkit `<h1>` and `<h2>` are indistinguishable](https://bugs.webkit.org/show_bug.cgi?id=57744)
- Tweaks CSS styles
- Support url-less menu items
- Support [alerts](https://hotdocsrails.com/markdown/#alerts) via Rails templates (remove custom markdown syntax)
- Rename `base.css` to `custom.css`
- Support external links in menu
- Add [announcement bar](https://hotdocsrails.com/announcement/)

## [0.4.0]

- Always install at `/hotdocs`
- Move images and stylesheets to `hotdocs/`

## [0.3.0]

- Replace deno & unifiedjs with kramdown & rouge (no more need for a JavaScript runtime!) (#23)
- Fix installer to set up css stylesheet tags and `website.css`
- Fix layout to allow to set up title
- Fix layout to allow for nil logo
- Fix to avoid overriding host helpers
- Allow replacing nav and footer
- Perf: Only load HotDocs assets when needed
- Fix Lighthouse accessibility errors
- Make search full screen on mobile and allow closing with button
- Allow single quotes in mderb templates
- Fetcher helper to fetch fresh content from a static page
- Prevent possible (implicit) styles overwrite

## [0.2.0]

- Constrain `max-width` for content & toc to look better on wider viewports
- Search (via lunr)

## [0.1.0]

- Initial release
