require "test_helper"

class SignupControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get signup_index_url
    assert_response :success
  end

  test "should get verify" do
    get signup_verify_url
    assert_response :success
  end

  test "should get callback" do
    get signup_callback_url
    assert_response :success
  end
end
