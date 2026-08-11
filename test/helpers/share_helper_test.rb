require "test_helper"

class ShareHelperTest < ActionView::TestCase
  setup do
    @event = events(:one)
    @user = users(:one)
  end

  test "timetable_image_filename for event" do
    controller.params = ActionController::Parameters.new(type: "event", d: "2026-08-09")
    assert_equal "#{@event.display_name}_0809.png", timetable_image_filename
  end

  test "timetable_image_filename for my timetable" do
    controller.params = ActionController::Parameters.new(type: "my-timetable", d: "2026-08-09")
    expected = "#{@user.name}の#{@event.display_name}マイタイムテーブル_0809.png"
    assert_equal expected, timetable_image_filename
  end

  test "safe_filename_component replaces invalid characters" do
    assert_equal "a_b_c", safe_filename_component("a/b:c")
  end
end
