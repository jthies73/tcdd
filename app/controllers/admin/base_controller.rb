module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin

    private

    # Fails closed outside dev/test: without ADMIN_PASSWORD nobody gets in.
    def authenticate_admin
      username = ENV["ADMIN_USERNAME"].to_s
      password = ENV["ADMIN_PASSWORD"].to_s
      return if Rails.env.local? && password.empty?

      authenticate_or_request_with_http_basic("Admin") do |given_username, given_password|
        password.present? &
          ActiveSupport::SecurityUtils.secure_compare(given_username, username) &
          ActiveSupport::SecurityUtils.secure_compare(given_password, password)
      end
    end
  end
end
