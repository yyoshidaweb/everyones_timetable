# frozen_string_literal: true

require "test_helper"

class ActiveStorageConfigTest < ActiveSupport::TestCase
  test "画像変換は無効（libvipsなしで起動できるようにする）" do
    assert_equal :disabled, ActiveStorage.variant_processor
  end
end
