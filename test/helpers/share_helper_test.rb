require "test_helper"

class ShareHelperTest < ActionView::TestCase
  setup do
    @event = events(:one)
    @user = users(:one)
    @days = @event.days.order(:date)
  end

  test "timetable_image_filename for event" do
    controller.params = ActionController::Parameters.new(type: "event")
    assert_equal "#{@event.event_key}_0809.png", timetable_image_filename(date: Date.new(2026, 8, 9))
  end

  test "timetable_image_filename for my timetable" do
    controller.params = ActionController::Parameters.new(type: "my-timetable")
    expected = "#{@event.event_key}_#{@user.username}_0809.png"
    assert_equal expected, timetable_image_filename(date: Date.new(2026, 8, 9))
  end

  test "timetable_image_day_options includes labels and filenames" do
    controller.params = ActionController::Parameters.new(type: "event")
    options = timetable_image_day_options
    assert_operator options.length, :>=, 1
    assert options.first.key?(:date)
    assert options.first.key?(:label)
    assert options.first.key?(:filename)
  end
end
