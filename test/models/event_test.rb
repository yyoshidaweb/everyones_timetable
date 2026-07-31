require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "future_all excludes unpublished events" do
    assert_not_includes Event.future_all, events(:unpublished)
  end

  test "past_all excludes unpublished events" do
    assert_not_includes Event.past_all, events(:unpublished)
  end

  test "is_private mirrors inverted is_published" do
    event = events(:one)
    assert event.is_published?
    assert_not event.is_private

    event.is_private = true
    assert_not event.is_published?
    assert event.is_private

    event.is_private = false
    assert event.is_published?
    assert_not event.is_private
  end
end
