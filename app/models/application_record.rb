# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Overwriting the sign_out redirect path method, so the
  # correct flash method is displayed
  def after_sign_out_path_for(_resource_or_scope)
    '/users/sign_in'
  end
end
