require "test_helper"

class AdventuresControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get adventures_index_url
    assert_response :success
  end

  test "should get new" do
    get adventures_new_url
    assert_response :success
  end

  test "should get show" do
    get adventures_show_url
    assert_response :success
  end
end
