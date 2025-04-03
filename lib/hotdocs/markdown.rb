require "open3"

class MarkdownHandler
  def self.prepare(engine)
    # Install npm packages
    # `capture3` raises if deno is not available
    Open3.capture3("deno --allow-read --allow-env --node-modules-dir=auto #{engine.root.join("lib/hotdocs/markdown.mjs")}", stdin_data: "")
  end

  def initialize(engine)
    @engine = engine
  end

  def call(template, source)
    compiled = ::HotdocsController.render(inline: source, handler: :erb)
    # `capture3` raises if deno is not available
    out, err, status = Open3.capture3("deno --allow-read --allow-env --node-modules-dir=auto #{@engine.root.join("lib/hotdocs/markdown.mjs")}", stdin_data: compiled)
    Rails.logger.error("Failed to compile markdown: #{err}") unless status.success?

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
