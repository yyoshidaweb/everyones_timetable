# frozen_string_literal: true

require "test_helper"

class Monitoring::SentryConfigTest < ActiveSupport::TestCase
  setup do
    @original_dsn = ENV["SENTRY_DSN"]
    @original_rails_env = ENV["RAILS_ENV"]
    @original_is_pull_request = ENV["IS_PULL_REQUEST"]
  end

  teardown do
    restore_env("SENTRY_DSN", @original_dsn)
    restore_env("RAILS_ENV", @original_rails_env)
    restore_env("IS_PULL_REQUEST", @original_is_pull_request)
  end

  test "本番かつDSNがある場合のみ有効になる" do
    ENV["RAILS_ENV"] = "production"
    ENV["SENTRY_DSN"] = "https://examplePublicKey@o0.ingest.sentry.io/0"
    ENV.delete("IS_PULL_REQUEST")

    assert Monitoring::SentryConfig.enabled?
    assert_equal ENV["SENTRY_DSN"], Monitoring::SentryConfig.dsn
  end

  test "ステージングでは無効になる" do
    ENV["RAILS_ENV"] = "staging"
    ENV["SENTRY_DSN"] = "https://examplePublicKey@o0.ingest.sentry.io/0"
    ENV.delete("IS_PULL_REQUEST")

    assert_not Monitoring::SentryConfig.enabled?
    assert_nil Monitoring::SentryConfig.dsn
  end

  test "PRプレビューでは無効になる" do
    ENV["RAILS_ENV"] = "production"
    ENV["SENTRY_DSN"] = "https://examplePublicKey@o0.ingest.sentry.io/0"
    ENV["IS_PULL_REQUEST"] = "true"

    assert_not Monitoring::SentryConfig.enabled?
    assert_nil Monitoring::SentryConfig.dsn
  end

  test "DSN未設定では無効になる" do
    ENV["RAILS_ENV"] = "production"
    ENV.delete("SENTRY_DSN")
    ENV.delete("IS_PULL_REQUEST")

    assert_not Monitoring::SentryConfig.enabled?
    assert_nil Monitoring::SentryConfig.dsn
  end

  test "トレーシングのサンプル率は無料枠向けに低い" do
    assert_operator Monitoring::SentryConfig::TRACES_SAMPLE_RATE, :<=, 0.1
    assert_operator Monitoring::SentryConfig::TRACES_SAMPLE_RATE, :>, 0
  end

  private
    def restore_env(key, value)
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
end
