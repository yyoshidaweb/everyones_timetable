# frozen_string_literal: true

require "test_helper"

class Monitoring::MalformedRequestMiddlewareTest < ActiveSupport::TestCase
  test "正常なリクエストはそのまま通す" do
    app = ->(_env) { [ 200, {}, [ "OK" ] ] }
    middleware = Monitoring::MalformedRequestMiddleware.new(app)

    status, _headers, body = middleware.call({})

    assert_equal 200, status
    assert_equal [ "OK" ], body
  end

  test "Rack::BadRequestの場合は400を返す" do
    app = lambda do |_env|
      raise Rack::Multipart::BoundaryTooLongError, "multipart boundary not found within limit"
    end
    middleware = Monitoring::MalformedRequestMiddleware.new(app)

    status, headers, body = middleware.call({})

    assert_equal 400, status
    assert_equal "text/html; charset=utf-8", headers["Content-Type"]
    assert_includes body.first, "400 Bad Request"
  end
end
