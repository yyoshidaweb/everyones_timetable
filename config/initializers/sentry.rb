# frozen_string_literal: true

require Rails.root.join("lib/monitoring/sentry_config")

Sentry.init do |config|
  config.dsn = Monitoring::SentryConfig.dsn
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.enabled_environments = %w[production]
  config.send_default_pii = false
  # 無料枠内に収めるため、パフォーマンス計測は低サンプル率にする
  config.traces_sample_rate = Monitoring::SentryConfig::TRACES_SAMPLE_RATE

  # 不正なmultipartリクエスト（ボットスキャン等）はクライアント起因のため除外する
  config.excluded_exceptions += %w[
    Rack::Multipart::BoundaryTooLongError
    Rack::Multipart::EmptyContentError
  ]
end
