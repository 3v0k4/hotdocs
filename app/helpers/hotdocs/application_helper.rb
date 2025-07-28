module Hotdocs
  module ApplicationHelper
    include Rails.application.helpers # Include host helpers

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

      # Needs to be on one line otherwise kramdown chokes
      link_to(options, html_options) do
        concat(content_tag(:span, name))

        concat(<<~SVG.gsub(/\n/, "").html_safe)
          <svg aria-hidden="true" viewBox="0 0 24 24" class="external-link__icon">
            <path fill="currentColor" d="M21 13v10h-21v-19h12v2h-10v15h17v-8h2zm3-12h-10.988l4.035 4-6.977 7.07 2.828 2.828 6.977-7.07 4.125 4.172v-11z"></path>
          </svg>
        SVG
      end
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

    def fetcher(id:, path:, fallback: nil, &)
      data = {
        controller: "fetcher",
        "fetcher-host-value": fetcher_host,
        "fetcher-path-value": path,
        "fetcher-fallback-value": fallback
      }
      content_tag(:div, id: id, data: data, style: "visibility: hidden;", &)
    end

    PATHS_BY_ALERT_TYPE = {
      "danger" => [
        "M15.362 5.214A8.252 8.252 0 0 1 12 21 8.25 8.25 0 0 1 6.038 7.047 8.287 8.287 0 0 0 9 9.601a8.983 8.983 0 0 1 3.361-6.867 8.21 8.21 0 0 0 3 2.48Z",
        "M12 18a3.75 3.75 0 0 0 .495-7.468 5.99 5.99 0 0 0-1.925 3.547 5.975 5.975 0 0 1-2.133-1.001A3.75 3.75 0 0 0 12 18Z"
      ],
      "warning" => [
        "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"
      ],
      "tip" => [
        "M12 18v-5.25m0 0a6.01 6.01 0 0 0 1.5-.189m-1.5.189a6.01 6.01 0 0 1-1.5-.189m3.75 7.478a12.06 12.06 0 0 1-4.5 0m3.75 2.383a14.406 14.406 0 0 1-3 0M14.25 18v-.192c0-.983.658-1.823 1.508-2.316a7.5 7.5 0 1 0-7.517 0c.85.493 1.509 1.333 1.509 2.316V18"
      ],
      "info" => [
        "m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z"
      ]
    }

    def alert(type, &block)
      paths = PATHS_BY_ALERT_TYPE.fetch(type.to_s)

      content_tag(:div, class: "alert alert--#{type}") do
        content_tag(:div) do
          concat(
            content_tag(:div, class: "alert__header") do
              concat(
                content_tag(
                  :svg,
                  class: "alert__icon",
                  xmlns: "http://www.w3.org/2000/svg",
                  fill: "none",
                  viewBox: "0 0 24 24",
                  "stroke-width": "1.5",
                  stroke: "currentColor"
                ) do
                  paths.each do |path|
                    concat(content_tag(:path, {}, "stroke-linecap": "round", "stroke-linejoin": "round", d: path))
                  end
                end
              )
              concat(content_tag(:span, type.upcase, class: "alert__label"))
            end
          )
          concat(content_tag(:div, class: "alert__content", &block))
        end
      end
    end

    private

    def active_link?(url)
      request.path == url
    end

    def compute_menu_r(items)
      return [ [], false ] if items.nil?

      new_items = items.map do |item|
        children, expanded_below = compute_menu_r(item[:children])
        active = active_link?(item.fetch(:url, nil))
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
            locals = { expanded: item.fetch(:expanded), label: item.fetch(:label), url: item.fetch(:url, nil) }
            concat(render partial: "hotdocs/menu_row", locals: locals)

            concat(menu_r(item.fetch(:children)))
          end)
        end
      end
    end
  end
end
