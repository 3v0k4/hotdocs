## [Unreleased]

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
