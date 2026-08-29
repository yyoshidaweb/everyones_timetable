require "application_system_test_case"

class TimetableCreationsTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  # フィクスチャと重複しない名前を使う
  EVENT_NAME = "システムテストフェス"
  PERFORMER_NAME = "システムテスト出演者"
  STAGE_NAME = "システムテストステージ"

  setup do
    Warden.test_mode!
    @user = users(:one)
    @date = Date.current + 7.days
    login_as @user, scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "タイムテーブルを作成して出演情報を追加できる" do
    # タイムテーブルを作成する
    visit root_path
    click_on "タイムテーブルを作る"
    fill_in "event[event_name_tag_attributes][name]", with: EVENT_NAME
    click_on "作成"

    # タイムテーブルページが開く
    assert_text "タイムテーブルを作成しました"
    event = @user.events.joins(:event_name_tag).find_by!(event_name_tags: { name: EVENT_NAME })
    assert_current_path show_timetable_path(event.event_key)

    # 出演情報作成ページを開く
    click_on "出演情報を追加"
    assert_current_path new_event_performance_path(event.event_key)

    # 出演者をモーダルから追加すると、追加した出演者が選択される
    click_on "出演者を追加"
    within "#modal" do
      fill_in "performer[performer_name_tag_attributes][name]", with: PERFORMER_NAME
      click_on "作成"
    end
    assert_searchable_select_selected "performer_select", PERFORMER_NAME

    # 開催日をモーダルから追加すると、追加した開催日が選択される
    click_on "開催日を追加"
    within "#modal" do
      fill_in "開催日", with: @date
      click_on "作成"
    end
    assert_selector :select, "出演日", selected: @date.to_s

    # ステージをモーダルから追加すると、追加したステージが選択される
    click_on "ステージを追加"
    within "#modal" do
      fill_in "stage[stage_name_tag_attributes][name]", with: STAGE_NAME
      click_on "作成"
    end
    assert_searchable_select_selected "stage_select", STAGE_NAME

    # 開始時刻と出演時間を選択して出演情報を作成する
    select "10", from: "performance[start_time_hour]"
    select "00", from: "performance[start_time_minute]"
    select "60", from: "出演時間"
    click_on "作成"

    # タイムテーブルページに戻り、作成した出演情報が表示される
    assert_text "出演情報を作成しました"
    assert_current_path show_timetable_path(event.event_key, d: @date)
    assert_text STAGE_NAME
    assert_text PERFORMER_NAME
    assert_text "10:00"
  end

  private

  # Tom Select は元の select を視覚的に隠すため、表示テキストと元 select の選択値の両方を確認する
  def assert_searchable_select_selected(container_id, selected_text)
    within "##{container_id}" do
      assert_selector ".ts-control", text: selected_text
      selected_option = find("select", visible: :all).find("option[selected]", visible: :all)
      assert_equal selected_text, selected_option.text.strip
    end
  end
end
