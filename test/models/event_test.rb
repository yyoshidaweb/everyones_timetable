require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "future_all excludes non-public events" do
    assert_not_includes Event.future_all, events(:unpublished)
    assert_not_includes Event.future_all, events(:unlisted)
  end

  test "past_all excludes non-public events" do
    assert_not_includes Event.past_all, events(:unpublished)
    assert_not_includes Event.past_all, events(:unlisted)
  end

  test "visibility enum values" do
    event = events(:one)
    assert event.visibility_public?

    event.visibility = :unlisted
    assert event.visibility_unlisted?

    event.visibility = :private
    assert event.visibility_private?
  end

  test "viewable_by_url returns true for public and unlisted" do
    assert events(:one).viewable_by_url?
    assert events(:unlisted).viewable_by_url?
    assert_not events(:unpublished).viewable_by_url?
  end

  test "search_indexable returns true only for public events" do
    assert events(:one).search_indexable?
    assert_not events(:unlisted).search_indexable?
    assert_not events(:unpublished).search_indexable?
  end

  test "recent_favorite_by excludes private events for other users" do
    favorites = Event.recent_favorite_by(users(:two))
    assert_not_includes favorites, events(:unpublished)
  end

  test "recent_favorite_by includes private events for owner" do
    favorites = Event.recent_favorite_by(users(:one))
    assert_includes favorites, events(:unpublished)
  end

  test "recent_favorite_by includes unlisted events" do
    favorites = Event.recent_favorite_by(users(:two))
    assert_includes favorites, events(:unlisted)
  end
end
