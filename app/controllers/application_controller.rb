# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Overwriting the sign_out redirect path method, so the
  # correct flash method is displayed
  def after_sign_out_path_for(_resource_or_scope)
    '/users/sign_in'
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit :sign_in, keys: %i[login password]
  end
end
