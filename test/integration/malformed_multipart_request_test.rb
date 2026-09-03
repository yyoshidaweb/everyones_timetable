# frozen_string_literal: true

require "test_helper"

class MalformedMultipartRequestTest < ActionDispatch::IntegrationTest
  test "不正なmultipart POSTは400を返す" do
    post "/",
      params: "x" * 20_000,
      headers: { "CONTENT_TYPE" => "multipart/form-data; boundary=----WebKitFormBoundary" }

    assert_response :bad_request
  end
end
