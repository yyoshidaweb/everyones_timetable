require "test_helper"

class FestivalTimeTest < ActiveSupport::TestCase
  test "converts clock time to festival minutes with 6:00 as day start" do
    assert_equal 6 * 60, FestivalTime.to_minutes(Time.zone.parse("06:00"))
    assert_equal 23 * 60, FestivalTime.to_minutes(Time.zone.parse("23:00"))
    assert_equal 24 * 60, FestivalTime.to_minutes(Time.zone.parse("00:00"))
    assert_equal 24 * 60 + 5 * 60, FestivalTime.to_minutes(Time.zone.parse("05:00"))
    assert_equal 24 * 60 + 5 * 60 + 59, FestivalTime.to_minutes(Time.zone.parse("05:59"))
  end

  test "returns nil when time is blank" do
    assert_nil FestivalTime.to_minutes(nil)
    assert_nil FestivalTime.end_minutes(nil, Time.zone.parse("01:00"))
  end

  test "adds 24 hours when end time wraps past midnight or 6:00" do
    assert_equal 25 * 60, FestivalTime.end_minutes(
      Time.zone.parse("23:00"),
      Time.zone.parse("01:00")
    )
    assert_equal 6 * 60 + 20 + 24 * 60, FestivalTime.end_minutes(
      Time.zone.parse("05:50"),
      Time.zone.parse("06:20")
    )
    assert_equal 10 * 60 + 30, FestivalTime.end_minutes(
      Time.zone.parse("10:00"),
      Time.zone.parse("10:30")
    )
  end

  test "floors and ceils festival minutes to the hour" do
    assert_equal 22 * 60, FestivalTime.floor_hour_minutes(Time.zone.parse("22:30"))
    assert_equal 25 * 60, FestivalTime.floor_hour_minutes(Time.zone.parse("01:30"))
    assert_equal 22 * 60, FestivalTime.ceil_hour_minutes(
      Time.zone.parse("21:00"),
      Time.zone.parse("22:00")
    )
    assert_equal 26 * 60, FestivalTime.ceil_hour_minutes(
      Time.zone.parse("01:00"),
      Time.zone.parse("01:30")
    )
  end

  test "builds wrapping hour slots from start to exclusive end" do
    assert_equal [ 10, 11, 12 ], FestivalTime.hour_slots(10 * 60, 13 * 60)
    assert_equal [ 22, 23, 0, 1 ], FestivalTime.hour_slots(22 * 60, 26 * 60)
  end

  test "hour select values start at 6 and end at 5" do
    hours = FestivalTime.hour_values
    assert_equal 6, hours.first
    assert_equal 5, hours.last
    assert_equal (6..23).to_a + (0..5).to_a, hours
  end
end
