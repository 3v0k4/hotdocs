class ApplicationController < ActionController::Base
  before_action :http_basic_authenticate, if: -> { Rails.env.production? }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def http_basic_authenticate
    http_basic_authenticate_or_request_with name: "hot-docs", password: ENV.fetch("HTTP_BASIC_AUTHENTICATION_PASSWORD")
  end
end
