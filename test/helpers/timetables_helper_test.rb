require "test_helper"
require "ostruct"

class TimetablesHelperTest < ActionView::TestCase
  test "builds daytime hour slots and height from 10:00 to 22:00" do
    performances = [
      performance_at("10:00", duration: 60),
      performance_at("21:00", duration: 60)
    ]

    assert_equal (10..21).to_a, time_slots_for_timetable(performances)
    assert_equal 12 * TimetablesHelper::TIMETABLE_REM_PER_HOUR, timetable_height_rem(performances)
    assert_equal 22, timetable_bottom_spacer_hour(performances)
  end

  test "wraps overnight hour slots from 22:00 to 02:00" do
    performances = [
      performance_at("22:00", duration: 60),
      performance_at("01:00", duration: 30)
    ]

    assert_equal [ 22, 23, 0, 1 ], time_slots_for_timetable(performances)
    assert_equal 4 * TimetablesHelper::TIMETABLE_REM_PER_HOUR, timetable_height_rem(performances)
    assert_equal 2, timetable_bottom_spacer_hour(performances)
  end

  test "places overnight performance below evening on the timetable" do
    evening = performance_at("22:00", duration: 60)
    overnight = performance_at("01:00", duration: 30)
    @performances = [ evening, overnight ]

    overnight_top = performance_top_rem(overnight)
    evening_top = performance_top_rem(evening)

    assert overnight_top > evening_top
    assert_operator overnight_top, :>, 0
  end

  private
    def performance_at(start_hm, duration:)
      start_time = Time.zone.parse(start_hm)
      OpenStruct.new(
        start_time: start_time,
        end_time: start_time + duration.minutes,
        duration: duration
      )
    end
end
