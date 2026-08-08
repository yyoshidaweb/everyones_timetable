# frozen_string_literal: true

require "test_helper"

class Monitoring::SentryConfigTest < ActiveSupport::TestCase
  EXAMPLE_DSN = "https://examplePublicKey@o0.ingest.sentry.io/0"

  setup do
    @original_rails_env = ENV["RAILS_ENV"]
    @original_is_pull_request = ENV["IS_PULL_REQUEST"]
  end

  teardown do
    restore_env("RAILS_ENV", @original_rails_env)
    restore_env("IS_PULL_REQUEST", @original_is_pull_request)
  end

  test "本番かつDSNがある場合のみ有効になる" do
    ENV["RAILS_ENV"] = "production"
    ENV.delete("IS_PULL_REQUEST")

    with_sentry_dsn(EXAMPLE_DSN) do
      assert Monitoring::SentryConfig.enabled?
      assert_equal EXAMPLE_DSN, Monitoring::SentryConfig.dsn
    end
  end

  test "ステージングでは無効になる" do
    ENV["RAILS_ENV"] = "staging"
    ENV.delete("IS_PULL_REQUEST")

    with_sentry_dsn(EXAMPLE_DSN) do
      assert_not Monitoring::SentryConfig.enabled?
      assert_nil Monitoring::SentryConfig.dsn
    end
  end

  test "PRプレビューでは無効になる" do
    ENV["RAILS_ENV"] = "production"
    ENV["IS_PULL_REQUEST"] = "true"

    with_sentry_dsn(EXAMPLE_DSN) do
      assert_not Monitoring::SentryConfig.enabled?
      assert_nil Monitoring::SentryConfig.dsn
    end
  end

  test "DSN未設定では無効になる" do
    ENV["RAILS_ENV"] = "production"
    ENV.delete("IS_PULL_REQUEST")

    with_sentry_dsn(nil) do
      assert_not Monitoring::SentryConfig.enabled?
      assert_nil Monitoring::SentryConfig.dsn
    end
  end

  test "トレーシングのサンプル率は無料枠向けに低い" do
    assert_operator Monitoring::SentryConfig::TRACES_SAMPLE_RATE, :<=, 0.1
    assert_operator Monitoring::SentryConfig::TRACES_SAMPLE_RATE, :>, 0
  end

  private
    def with_sentry_dsn(dsn)
      credentials = Object.new
      credentials.define_singleton_method(:dig) do |*keys|
        keys == [ :sentry, :dsn ] ? dsn : nil
      end

      Rails.application.stub(:credentials, credentials) { yield }
    end

    def restore_env(key, value)
      if value.nil?
        ENV.delete(key)
      else
        ENV[key] = value
      end
    end
end
