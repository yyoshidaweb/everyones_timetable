require "test_helper"

class PerformancesHelperTest < ActionView::TestCase
  test "hour select options start at 6 and end at 29" do
    hours = time_select_options[:hours].map(&:last)

    assert_equal "06", time_select_options[:hours].first.first
    assert_equal "29", time_select_options[:hours].last.first
    assert_equal 6, hours.first
    assert_equal 29, hours.last
    assert_equal (6..23).to_a + (24..29).to_a, hours
  end
end
