module HotdocsHelper
  # @return [Logo, nil]
  def logo
    Struct.new(:src, :alt).new(asset_path("hotdocs/hotdocs.svg"), "A humanized and happy hot dog")
  end

  def title
    "HotDocs"
  end

  def nav_left_items(classes)
    [
      active_link_to("Docs", root_path, class: Array(classes))
    ]
  end

  def nav_right_items(classes)
    [
      external_link_to("GitHub", "https://github.com/3v0k4/hotdocs", class: Array(classes))
    ]
  end

  def menu_items
    [
      { label: "Welcome", url: root_path },
      {
        label: "Quickstart", url: quickstart_path, children: [
          { label: "Embedded", url: embedded_path },
          { label: "Standalone", url: standalone_path }
        ]
      },
      { label: "Markdown", url: markdown_path },
      { label: "Static export", url: static_export_path },
      {
        label: "Components", url: components_path, children: [
          { label: "Nav / Sidenav", url: nav_path },
          { label: "Table of contents", url: toc_path },
          { label: "Search", url: search_path },
          { label: "Light / Dark", url: light_dark_path },
          { label: "Footer", url: footer_path },
          { label: "Helpers", url: helpers_path }
        ]
      }
    ]
  end

  def repository_base_url
    "https://github.com/3v0k4/hotdocs/tree/main/website"
  end

  def footer_items
    [
      {
        heading: "Contribute",
        items: [
          external_link_to("Source Code", "https://github.com/3v0k4/hotdocs", class: "footer__link")
        ]
      },
      {
        heading: "Community",
        items: [
          external_link_to("GitHub Discussions", "https://github.com/3v0k4/hotdocs/discussions", class: "footer__link")
        ]
      },
      {
        heading: "(il)Legal",
        items: [
          "Nothing to see here."
        ]
      },
      {
        heading: "HotDocs",
        items: [
          "Write your docs with Ruby on Rails."
        ]
      }
    ]
  end

  def fetcher_host
    "http://127.0.0.1:3000"
  end
end
