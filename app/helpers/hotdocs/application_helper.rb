module Hotdocs
  module ApplicationHelper
    # Include host helpers.
    include Rails.application.helpers

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
      default_html_options = {
        class: "external-link",
        target: "_blank",
        rel: [ "noopener", "noreferrer" ]
      }

      html_options = html_options.to_h.merge(default_html_options) do |_, old, new|
        [ *Array(old), *Array(new) ].join(" ")
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

    def menu(items = menu_items)
      menu_r(compute_menu(items))
    end

    def compute_menu(items)
      compute_menu_r(items).first
    end

    def edit_link(base_url = repository_base_url)
      return nil if base_url.nil?
      return nil if base_url.empty?

      template_path = lookup_context
        .find_template("#{controller_path}/#{action_name}")
        .identifier
        .sub(Rails.root.to_s + "/", "")
      href = "#{base_url}/#{template_path}"

      html_options = {
        class: "edit-link",
        target: "_blank",
        rel: [ "noopener", "noreferrer" ]
      }

      link_to(href, html_options) do
        concat(<<~SVG.html_safe)
          <svg aria-hidden="true" viewBox="0 0 40 40" class="edit-link__icon">
            <path fill="currentColor" d="m34.5 11.7l-3 3.1-6.3-6.3 3.1-3q0.5-0.5 1.2-0.5t1.1 0.5l3.9 3.9q0.5 0.4 0.5 1.1t-0.5 1.2z m-29.5 17.1l18.4-18.5 6.3 6.3-18.4 18.4h-6.3v-6.2z"></path>
          </svg>
        SVG

        concat(content_tag(:span, "Edit this page"))
      end
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
            concat(render partial: "hotdocs/menu_row", locals: locals)

            concat(menu_r(item.fetch(:children)))
          end)
        end
      end
    end
  end
end
