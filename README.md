# HotDocs: Write your docs with Ruby on Rails

<div align="center">
  <img width="200" width="200" src=".github/images/hotdocs.svg" />
</div>

Let's stop the JavaScript madness:

HotDocs is a set of optimized Rails components & tools for writing docs:
- Write your docs from scratch
- Embed docs in your Rails app

[**Get Started**](https://hotdocsrails.odone.me)

## Comparison

| Feature                                                   | HotDocs | Jekyll | Docusaurus |
|-----------------------------------------------------------|---------|--------|------------|
| Ruby on Rails (database, Hotwire, etc.)                   | ✅      | ❌     | ❌         |
| Embed docs in an existing Rails app                       | ✅      | ❌     | ❌         |
| Standalone docs                                           | ✅      | ✅     | ✅         |
| Styled components you can customize                       | ✅      | ✅     | ✅         |
| Markdown (with syntax highlight & themes)                 | ✅      | ✅     | ✅         |
| Static export                                             | ✅      | ✅     | ✅         |
| Search                                                    | ✅      | 🔌     | 🔌         |
| Light / Dark                                              | ✅      | 🔌     | ✅         |
| Open source                                               | ✅      | ✅     | ✅         |
| Free                                                      | ✅      | ✅     | ✅         |

**Anything missing? Suggestions?** See how to contribute below.

## Demo

HotDocs uses itself for its docs: [check the demo out](https://hotdocsrails.odone.me).

## Development

In its current state, HotDocs is a mountable Rails engine.

The HotDocs website is a Rails app configured to use the HotDocs engine. Run it with:

```bash
bin/dev
bin/rails test
```

To release a new version:
- Update the version number in `version.rb`
- Run `bundle exec rake release`, which will
  - Create a git tag for the version
  - Push git commits and the created tag
  - Push the `.gem` file to [rubygems.org](https://rubygems.org)

## Contributing

Let's create a Rails alternative to (just) Ruby and JavaScript docs frameworks:
- Chime in the [discussions](https://github.com/3v0k4/hotdocs/discussions) with your feedback and wishes
- Open an [issue](https://github.com/3v0k4/hotdocs/issues)
- Submit a [pull request](https://github.com/3v0k4/hotdocs/pulls)
