require "test_helper"

class PerformerTest < ActiveSupport::TestCase
  def setup
    @performer = performers(:one)
    @stage = stages(:one)
    @day = days(:one)
  end

  # 出演者を削除すると紐づいている出演情報も削除される
  test "should destroy performer" do
    performer = @performer
    performance = performances(:one)

    assert_equal performer.id, performance.performer_id

    assert_difference("Performer.count", -1) do
      assert_difference("Performance.count", -2) do
        performer.destroy
      end
    end
    # 削除されたことを確認
    assert_raises(ActiveRecord::RecordNotFound) do
      performance.reload
    end
  end

  # 出演情報は開催日と6時起点の開始時刻順
  test "performances are ordered by festival day and time" do
    overnight = Performance.create!(
      performer: @performer,
      day: @day,
      stage: stages(:two),
      start_time: Time.zone.parse("01:00"),
      duration: 30
    )
    evening = Performance.create!(
      performer: @performer,
      day: @day,
      stage: stages(:two),
      start_time: Time.zone.parse("22:00"),
      duration: 30
    )

    assert_operator @performer.performances.index(evening), :<, @performer.performances.index(overnight)
  end
end
