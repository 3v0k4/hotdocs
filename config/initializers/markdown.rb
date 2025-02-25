require "open3"

module Handlers
  class MarkdownHandler
    def call(template, source)
      compiled = ::ApplicationController.render(inline: source, handler: :erb)
      # `capture3` raises if deno is not available
      out, err, _status = Open3.capture3("deno --allow-read --allow-env --node-modules-dir=auto config/initializers/markdown.mjs", stdin_data: compiled)
      Rails.logger.error(err) if !err.empty?

      if !err.empty? && !err.include?("The following packages are deprecated")
        # Render the compiled erb (without the md step).
        # It won't look great, but better than nothing.
        return <<~STRING
          @output_buffer.safe_append='#{compiled}'.freeze;
          @output_buffer
        STRING
      end

      content_fors = ActionView::Template::Handlers::ERB
        .new
        .call(template, source)
        .split(";")
        .grep(/content_for.*\(.*:/)

      <<~STRING
        #{content_fors.join(";")}
        @output_buffer.safe_append='#{out}'.freeze;
        @output_buffer
      STRING
    end
  end
end

ActionView::Template.register_template_handler :mderb, Handlers::MarkdownHandler.new
