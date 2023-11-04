require "test_helper"

class AccountControllerTest < ActionDispatch::IntegrationTest
  test "should get register" do
    get account_register_url
    assert_response :success
  end

  test "should get verify" do
    get account_verify_url
    assert_response :success
  end
end
