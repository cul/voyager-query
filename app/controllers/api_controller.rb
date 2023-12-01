# frozen_string_literal: true
class ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  private

  # Renders with an :unauthorized status if no request token is provided, or renders with a
  # :forbidden status if the request uses an invalid request token. This method should be
  # used as a before_action callback for any controller actions that require authorization.
  def authenticate_request_token
    # Show the contents of the packet for debugging purposes
    # pp request.headers.env.select{|k, _| k.in?(ActionDispatch::Http::Headers::CGI_VARIABLES) || k =~ /^HTTP_/}

    authenticate_or_request_with_http_token do |token, _options|
      ActiveSupport::SecurityUtils.secure_compare(VOYAGER_CONFIG['remote_request_api_key'], token)
    end
  end
end
