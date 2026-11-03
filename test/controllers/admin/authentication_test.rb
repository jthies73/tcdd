require "test_helper"

module Admin
  class AuthenticationTest < ActionDispatch::IntegrationTest
    setup do
      @previous = ENV.values_at("ADMIN_USERNAME", "ADMIN_PASSWORD")
      ENV["ADMIN_USERNAME"] = "admin"
      ENV["ADMIN_PASSWORD"] = "secret"
    end

    teardown do
      ENV["ADMIN_USERNAME"], ENV["ADMIN_PASSWORD"] = @previous
    end

    test "rejects requests without credentials" do
      get admin_clean_ups_path
      assert_response :unauthorized
    end

    test "rejects wrong credentials" do
      get admin_clean_ups_path, headers: auth_header("admin", "wrong")
      assert_response :unauthorized
    end

    test "allows the configured credentials" do
      get admin_clean_ups_path, headers: auth_header("admin", "secret")
      assert_response :success
    end

    private

    def auth_header(username, password)
      { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password) }
    end
  end
end
