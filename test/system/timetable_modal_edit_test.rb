require "application_system_test_case"

class TimetableModalEditTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  setup do
    Warden.test_mode!
    @user = users(:one)
    @event = events(:one)
    @performer = performers(:one)
    @stage = stages(:one)
    login_as @user, scope: :user
  end

  teardown do
    Warden.test_reset!
  end

  test "タイムテーブルの出演者モーダルから編集フォームへ差し替えられる" do
    visit show_timetable_path(@event.event_key)

    assert_text @performer.display_name
    find("a[data-turbo-frame='modal']", text: @performer.display_name, match: :first).click

    within "#modal" do
      assert_text @performer.display_name
      find("a[href='#{edit_event_performer_path(@event.event_key, @performer)}'][data-action='click->modal#navigate']").click
    end

    assert_current_path show_timetable_path(@event.event_key)

    within "#modal" do
      assert_button "更新"
      assert_no_link "詳細→"
    end
  end

  test "タイムテーブルのステージモーダルから編集フォームへ差し替えられる" do
    visit show_timetable_path(@event.event_key)

    find("a.stage-header-col[data-turbo-frame='modal']", text: @stage.display_name).click

    within "#modal" do
      assert_text @stage.display_name
      find("a[href='#{edit_event_stage_path(@event.event_key, @stage)}'][data-action='click->modal#navigate']").click
    end

    assert_current_path show_timetable_path(@event.event_key)

    within "#modal" do
      assert_button "更新"
    end
  end
end
