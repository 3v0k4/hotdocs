require "kramdown"
require "kramdown-parser-gfm"
require "rouge"

require_relative "kramdown_alerts"

class MarkdownHandler
  def call(template, source)
    # If the template contains a `fetcher`, do not allow Rails to cache the page.
    if source.match?(%r{<%= fetcher.* do %>})
      ActionView::PathRegistry.all_resolvers.each do |resolver|
        resolver.instance_eval do
          @unbound_templates.delete(template.virtual_path)
        end
      end
    end

    compiled_template = ::HotdocsController.render(inline: source, handler: :erb)
    out = Kramdown::Document.new(
      compiled_template,
      input: "GFM",
      auto_ids: false,
      syntax_highlighter_opts: { css_class: "highlight" }
    ).to_html

    content_fors = ActionView::Template::Handlers::ERB
      .new
      .call(template, source)
      .split(";")
      .grep(/content_for.*\(.*:/)

    <<~STRING
      #{content_fors.join(";")}
      @output_buffer.safe_append='#{out.gsub("'", "\\\\'")}'.freeze;
      @output_buffer
    STRING
  end
end
