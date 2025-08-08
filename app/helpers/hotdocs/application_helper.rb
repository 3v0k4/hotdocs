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
          <svg aria-hidden="true" class="external-link__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640">
            <!--!Font Awesome Free v7.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.-->
            <path fill="currentColor" d="M384 64C366.3 64 352 78.3 352 96C352 113.7 366.3 128 384 128L466.7 128L265.3 329.4C252.8 341.9 252.8 362.2 265.3 374.7C277.8 387.2 298.1 387.2 310.6 374.7L512 173.3L512 256C512 273.7 526.3 288 544 288C561.7 288 576 273.7 576 256L576 96C576 78.3 561.7 64 544 64L384 64zM144 160C99.8 160 64 195.8 64 240L64 496C64 540.2 99.8 576 144 576L400 576C444.2 576 480 540.2 480 496L480 416C480 398.3 465.7 384 448 384C430.3 384 416 398.3 416 416L416 496C416 504.8 408.8 512 400 512L144 512C135.2 512 128 504.8 128 496L128 240C128 231.2 135.2 224 144 224L224 224C241.7 224 256 209.7 256 192C256 174.3 241.7 160 224 160L144 160z"/>
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
          <svg aria-hidden="true" class="edit-link__icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 640">
            <!--!Font Awesome Free v7.0.0 by @fontawesome - https://fontawesome.com License - https://fontawesome.com/license/free Copyright 2025 Fonticons, Inc.-->
            <path fill="currentColor" d="M416.9 85.2L372 130.1L509.9 268L554.8 223.1C568.4 209.6 576 191.2 576 172C576 152.8 568.4 134.4 554.8 120.9L519.1 85.2C505.6 71.6 487.2 64 468 64C448.8 64 430.4 71.6 416.9 85.2zM338.1 164L122.9 379.1C112.2 389.8 104.4 403.2 100.3 417.8L64.9 545.6C62.6 553.9 64.9 562.9 71.1 569C77.3 575.1 86.2 577.5 94.5 575.2L222.3 539.7C236.9 535.6 250.2 527.9 261 517.1L476 301.9L338.1 164z"/>
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

    def external_url?(url)
      !URI.parse(url).host.nil?
    rescue URI::InvalidURIError
      false
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
