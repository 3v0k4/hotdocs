module ApplicationHelper
  def active_link_to(name = nil, options = nil, html_options = nil, &block)
    if options.is_a?(String) && request.path == options
      html_options = html_options.to_h.merge(class: "active") do |_, old, new|
        [ *Array(old), new ].join(" ")
      end
      link_to(name, options, html_options, &block)
    else
      link_to(name, options, html_options, &block)
    end
  end
end
