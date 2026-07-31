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

  test "recent_favorite_by excludes unpublished events for other users" do
    favorites = Event.recent_favorite_by(users(:two))
    assert_not_includes favorites, events(:unpublished)
  end

  test "recent_favorite_by includes unpublished events for owner" do
    favorites = Event.recent_favorite_by(users(:one))
    assert_includes favorites, events(:unpublished)
  end
end
