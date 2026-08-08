# frozen_string_literal: true

module Monitoring
  # Sentryの有効条件と無料枠向けのサンプルレートをまとめる
  module SentryConfig
    # 無料枠を意識した低めのトレーシングサンプル率
    TRACES_SAMPLE_RATE = 0.05

    module_function

    # 本番のみ。PRプレビュー（IS_PULL_REQUEST=true）やDSN未設定では無効
    def dsn
      return if preview_environment?
      return unless production_environment?

      ENV["SENTRY_DSN"].presence
    end

    def enabled?
      dsn.present?
    end

    def production_environment?
      ENV.fetch("RAILS_ENV", "development") == "production"
    end

    def preview_environment?
      ENV["IS_PULL_REQUEST"] == "true"
    end
  end
end
