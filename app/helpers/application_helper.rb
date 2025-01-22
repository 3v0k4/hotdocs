module ApplicationHelper
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

  def active_link?(url)
    request.path == url
  end

  def menu(items)
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
          concat(render partial: "root/menu_row", locals: locals)

          concat(menu_r(item.fetch(:children)))
        end)
      end
    end
  end
end
