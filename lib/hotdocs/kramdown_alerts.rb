module Kramdown
  class Element
    def to_h
      {
        children: children.map(&:to_h),
        type:,
        value:
      }
    end
  end
end

module Alert
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

  def convert_blockquote(el, indent)
    child = el.children[0]

    case child.to_h
    in {
      type: :p,
      children: [
        { type: :text, value: /\A\[!(INFO|TIP|WARNING|DANGER)\]\z/ },
        { type: :br },
        *
      ]
    }
      alert_type = $+.downcase
      child.children.slice!(0, 2) # remove :text & :br

      svg = Kramdown::Element.new(
        :html_element,
        :svg,
        {
          class: "alert__icon",
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: "0 0 24 24",
          "stroke-width": "1.5",
          stroke: "currentColor"
        }
      )

      PATHS_BY_ALERT_TYPE[alert_type].each do |path|
        svg.children << Kramdown::Element.new(:html_element, :path, {
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          d: path
        })
      end

      label = Kramdown::Element.new(:html_element, :span, { class: "alert__label" })
      label.children << Kramdown::Element.new(:text, alert_type.upcase)

      header = Kramdown::Element.new(:html_element, :div, { class: "alert__header" })
      header.children << svg
      header.children << label

      content = Kramdown::Element.new(:html_element, :div, { class: "alert__content" })
      content.children.push(*el.children)

      alert = Kramdown::Element.new(:html_element, :div, {})
      alert.children << header
      alert.children << content

      format_as_block_html(
        "div",
        { class: "alert alert--#{alert_type}" },
        format_as_indented_block_html("div", {}, inner(alert, indent), indent),
        indent
      )
    else
      super
    end
  end
end

Kramdown::Converter::Html.prepend(Alert)
