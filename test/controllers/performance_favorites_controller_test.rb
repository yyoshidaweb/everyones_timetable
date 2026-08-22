require "test_helper"

class PerformanceFavoritesControllerTest < ActionDispatch::IntegrationTest
  # Devise のテストヘルパーをインクルード
  include Devise::Test::IntegrationHelpers

  # 各テストの前に実行されるセットアップメソッド
  # fixtures に登録済みの event ラベルを利用
  setup do
    # Google 認証のテスト用ユーザーを作成
    @user = users(:one) # fixtures の user を利用
    # テスト用のログイン状態を再現
    sign_in @user
    @event = events(:one)
    @favorite = performance_favorites(:user_one_to_performance_one)
    @not_favorite_performance = @event.performances.third
    # リファラーを設定（お気に入り登録・解除後のリダイレクト先として使用）
    @referer = event_performers_path(@event.event_key)
  end

  test "お気に入り登録できる" do
    assert_difference("PerformanceFavorite.count", 1) do
      post performance_favorites_path,
            params: { performance_id: @not_favorite_performance.id },
            headers: { "HTTP_REFERER" => @referer }
    end
    # 登録後はリファラーにリダイレクトされることを確認
    assert_redirected_to @referer
  end

  test "turbo_stream: お気に入り登録するとボタンが更新される" do
    assert_difference("PerformanceFavorite.count", 1) do
      post performance_favorites_path,
            params: { performance_id: @not_favorite_performance.id },
            as: :turbo_stream
    end
    assert_response :success
    favorite = PerformanceFavorite.find_by!(user: @user, performance: @not_favorite_performance)
    assert_select "turbo-stream[action='replace'][target=?]",
                  "favorite_performance_#{@not_favorite_performance.id}" do
      assert_select "form[action=?]", performance_favorite_path(favorite) do
        assert_select "input[name=_method][value=delete]"
      end
    end
    assert_select "turbo-stream[action='replace'][target=?]",
                  "favorite_marker_performance_#{@not_favorite_performance.id}" do
      assert_select "span.favorite-marker"
    end
    assert_select "turbo-stream[action='replace'][target=my_timetable]", count: 0
  end

  test "turbo_stream: マイタイムテーブルでお気に入り登録するとカードが表示される" do
    performance = performances(:two)
    referer = show_my_timetable_url(event_key: @event.event_key, username: @user.username)

    assert_difference("PerformanceFavorite.count", 1) do
      post performance_favorites_path,
            params: { performance_id: performance.id },
            headers: { "HTTP_REFERER" => referer },
            as: :turbo_stream
    end
    assert_response :success
    assert_select "turbo-stream[action='replace'][target=my_timetable]" do
      assert_select "div#my_timetable.h-full"
      assert_select "a#my_timetable_performance_#{performance.id}"
    end
  end

  test "お気に入り解除できる" do
    assert_difference("PerformanceFavorite.count", -1) do
      delete performance_favorite_path(@favorite),
              headers: { "HTTP_REFERER" => @referer }
    end
    # 解除後はリファラーにリダイレクトされることを確認
    assert_redirected_to @referer
  end

  test "turbo_stream: お気に入り解除するとボタンが更新される" do
    performance = @favorite.performance
    assert_difference("PerformanceFavorite.count", -1) do
      delete performance_favorite_path(@favorite), as: :turbo_stream
    end
    assert_response :success
    assert_select "turbo-stream[action='replace'][target=?]",
                  "favorite_performance_#{performance.id}" do
      assert_select "form[action=?]", performance_favorites_path(performance_id: performance.id) do
        assert_select "input[name=_method][value=delete]", count: 0
      end
    end
    assert_select "turbo-stream[action='replace'][target=?]",
                  "favorite_marker_performance_#{performance.id}" do
      assert_select "span.favorite-marker", count: 0
    end
    assert_select "turbo-stream[action='replace'][target=my_timetable]", count: 0
  end

  test "turbo_stream: マイタイムテーブルでお気に入り解除するとカードが消える" do
    performance = @favorite.performance
    referer = show_my_timetable_url(event_key: @event.event_key, username: @user.username)

    assert_difference("PerformanceFavorite.count", -1) do
      delete performance_favorite_path(@favorite),
             headers: { "HTTP_REFERER" => referer },
             as: :turbo_stream
    end
    assert_response :success
    assert_select "turbo-stream[action='replace'][target=my_timetable]" do
      assert_select "div#my_timetable.h-full"
      assert_select "a#my_timetable_performance_#{performance.id}", count: 0
    end
  end
end
