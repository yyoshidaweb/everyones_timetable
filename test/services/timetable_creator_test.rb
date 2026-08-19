require "test_helper"

class TimetableCreatorTest < ActionDispatch::IntegrationTest
  setup do
    @no_performance_event = events(:no_performance_event)
    @no_performance_event_day = days(:no_performance_event_day)
    @json = JSON.parse(file_fixture("timetable_json.json").read)
    @timetable_json_without_stages = JSON.parse(file_fixture("timetable_json_without_stages.json").read)
    @timetable_json_without_performance = JSON.parse(file_fixture("timetable_json_without_performance.json").read)
  end

  # タイムテーブルJSONからStage、Performer、Performanceを作成でき、AI利用回数が増加する
  test "should create stages, performers, and performances from timetable json and increase AI usage count" do
    original_ai_timetable_count = @no_performance_event.user.ai_timetable_count
    assert_difference "Stage.count", +2 do
      assert_difference "Performer.count", +3 do
        assert_difference "Performance.count", +3 do
          TimetableCreator.create_from_json(
            json: @json,
            event: @no_performance_event,
            day: @no_performance_event_day
          )
        end
      end
    end
    assert_equal original_ai_timetable_count + 1, @no_performance_event.user.ai_timetable_count
  end

  # タイムテーブルJSONにstageが含まれていない場合はエラーを返し、AI利用回数は増加しない
  test "should return error if no stages in json and not increase AI usage count" do
    original_ai_timetable_count = @no_performance_event.user.ai_timetable_count
    assert_equal({ success: false, error: "タイムテーブルを認識できませんでした" },
      TimetableCreator.create_from_json(
        json: @timetable_json_without_stages,
        event: @no_performance_event,
        day: @no_performance_event_day
      )
    )
    assert_equal original_ai_timetable_count, @no_performance_event.user.ai_timetable_count
  end

  # タイムテーブルJSONにperformanceが含まれていない場合はエラーを返す
  test "should return error if no performances in json" do
    assert_equal({ success: false, error: "タイムテーブルを認識できませんでした" },
      TimetableCreator.create_from_json(
        json: @timetable_json_without_performance,
        event: @no_performance_event,
        day: @no_performance_event_day
      )
    )
  end

  # 0時をまたぐ出演は6時起点の順でdurationを計算する
  test "calculates duration across midnight in festival time order" do
    json = {
      "stages" => [
        {
          "stage_name" => "OvernightStage",
          "performances" => [
            { "performer_name" => "LateNight", "start_time" => "00:10" },
            { "performer_name" => "Evening", "start_time" => "23:50" }
          ]
        }
      ]
    }

    result = TimetableCreator.create_from_json(
      json: json,
      event: @no_performance_event,
      day: @no_performance_event_day
    )

    assert result[:success]
    performances = Performance.joins(:performer).where(performers: { event_id: @no_performance_event.id })
    evening = performances.find { |performance| performance.start_time.hour == 23 && performance.start_time.min == 50 }
    late_night = performances.find { |performance| performance.start_time.hour == 0 && performance.start_time.min == 10 }
    assert_equal 10, evening.duration
    assert_equal 10, late_night.duration
  end
end
