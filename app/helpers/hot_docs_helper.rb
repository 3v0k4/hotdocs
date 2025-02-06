module HotDocsHelper
  def active_link_to(name = nil, options = nil, html_options = nil, &block)
    if options.is_a?(String) && active_link?(options)
      html_options = html_options.to_h.merge(class: "active") do |_, old, new|
        [ *Array(old), new ].join(" ")
      end
      link_to(name, options, html_options, &block)
    else
      link_to(name, options, html_options, &block)
    end
  end

  def external_link_to(name = nil, options = nil, html_options = nil)
    html_options = html_options.to_h.merge(class: "external-link") do |_, old, new|
      [ *Array(old), new ].join(" ")
    end

    link_to(options, html_options) do
      concat(content_tag(:span, name))

      concat(<<~SVG.html_safe)
        <svg aria-hidden="true" viewBox="0 0 24 24" class="external-link__icon">
          <path fill="currentColor" d="M21 13v10h-21v-19h12v2h-10v15h17v-8h2zm3-12h-10.988l4.035 4-6.977 7.07 2.828 2.828 6.977-7.07 4.125 4.172v-11z"></path>
        </svg>
      SVG
    end
  end

  def active_link?(url)
    request.path == url
  end

  def nav_left_items(classes)
    require "ostruct"

    [
      active_link_to("Docs", root_path, class: Array(classes))
    ]
  end

  def nav_right_items(classes)
    require "ostruct"

    [
      external_link_to("GitHub", "https://github.com/3v0k4/hot_docs", class: Array(classes))
    ]
  end

  # { label: "", url: *_path, children: [], expanded: true }
  def menu_items
    [
      { label: "Welcome", url: root_path },
      {
        label: "Quickstart", url: quickstart_path, children: [
          { label: "Embedded", url: embedded_path },
          { label: "Standalone", url: standalone_path }
        ]
      },
      {
        label: "Components", url: components_path, children: [
          { label: "Nav / Sidenav", url: nav_path },
          { label: "Table of contents", url: toc_path },
          { label: "Markdown", url: markdown_path }, # page unreset, syntax highlight
          { label: "Search", url: search_path }, # lunr
          { label: "Static export", url: static_export_path },
          { label: "Light / Dark", url: light_dark_path },
          { label: "Footer", url: footer_path },
          { label: "Micro-components", url: microcomponents_path }
        ]
      }
    ]
  end

  def menu(items = menu_items)
    menu_r(compute_menu(items))
  end

  def compute_menu(items)
    compute_menu_r(items).first
  end

  private

  def compute_menu_r(items)
    return [ [], false ] if items.nil?

    new_items = items.map do |item|
      children, expanded_below = compute_menu_r(item[:children])
      active = active_link?(item.fetch(:url))
      expanded = expanded_below || item[:expanded] || active
      { **item, expanded: expanded, children: children }
    end

    [ new_items, new_items.any? { _1[:expanded] } ]
  end

  def menu_r(items)
    return nil if items.size == 0

    content_tag(:ul, class: "menu__section") do
      items.each do |item|
        concat(content_tag(:li) do
          locals = { expanded: item.fetch(:expanded), label: item.fetch(:label), url: item.fetch(:url) }
          concat(render partial: "hot_docs/menu_row", locals: locals)

          concat(menu_r(item.fetch(:children)))
        end)
      end
    end
  end
end
