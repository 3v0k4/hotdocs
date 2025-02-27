module ApplicationHelper
  def website_menu_items
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

  def website_repository_base_url
    "https://github.com/3v0k4/hot_docs/blob/main"
  end
end
