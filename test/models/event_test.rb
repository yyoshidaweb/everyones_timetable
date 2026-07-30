require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "future_all excludes unpublished events" do
    assert_not_includes Event.future_all, events(:unpublished)
  end

  test "past_all excludes unpublished events" do
    assert_not_includes Event.past_all, events(:unpublished)
  end
end
