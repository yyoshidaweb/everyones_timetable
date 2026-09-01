# frozen_string_literal: true

module Monitoring
  # 不正なmultipartリクエスト（ボットスキャン等）でRack::BadRequestが発生した際、
  # 500ではなく400を返す。Rack::MethodOverrideより外側で捕捉する。
  class MalformedRequestMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    rescue Rack::BadRequest
      bad_request_response
    end

    private

      def bad_request_response
        body = bad_request_body
        [
          400,
          {
            "Content-Type" => "text/html; charset=utf-8",
            "Content-Length" => body.bytesize.to_s
          },
          [ body ]
        ]
      end

      def bad_request_body
        @bad_request_body ||= Rails.root.join("public/400.html").read
      end
  end
end
