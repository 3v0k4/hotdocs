class ApplicationController < ActionController::Base
  http_basic_authenticate_with name: "with", password: "ketchup"

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
