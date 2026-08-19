class PerformanceFavoritesController < ApplicationController
  # ユーザがログインしているかどうかを確認し、ログインしていない場合はユーザをログインページにリダイレクトする。
  before_action :authenticate_user!

  # 出演情報お気に入り登録実行
  def create
    @performance = Performance.find(params[:performance_id])
    favorite = current_user.performance_favorites.create!(performance: @performance)
    respond_to do |format|
      format.turbo_stream do
        @toggled_favorite_id = favorite.id
        prepare_my_timetable_refresh
        render :refresh
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  # 出演情報お気に入り登録解除実行
  def destroy
    favorite = current_user.performance_favorites.find(params[:id])
    @performance = favorite.performance
    favorite.destroy!
    respond_to do |format|
      format.turbo_stream do
        @toggled_favorite_id = nil
        prepare_my_timetable_refresh
        render :refresh
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  private
    # マイタイムテーブル上でのお気に入り変更なら、背面のグリッドを描き直す
    def prepare_my_timetable_refresh
      @event = @performance.performer.event
      return unless my_timetable_referer?

      @refresh_my_timetable = true
      @user = current_user
      @my_timetable_view = true
      @timetable_view = true
      @days = @event.days.order(:date)
      @stages = @event.stages.order(:position).includes(:stage_name_tag)
      @selected_date = my_timetable_selected_date_from_referer || @days.first&.date
      @performances = Performance.timetable_ready_for_event_on_date(@event, @selected_date)
      favorite_ids = @user.favorite_performance_map_by_performances(@performances).keys
      @performances = @performances.where(id: favorite_ids)
      @favorite_performance_map = current_user.favorite_performance_map_by_performances(@performances)
      @performances_by_stage = @performances.group_by(&:stage_id)
      @stages = @stages.where(id: @performances_by_stage.keys)
    end

    def my_timetable_referer?
      return false if request.referer.blank?

      path = (URI.parse(request.referer).path || "").delete_suffix("/")
      path == show_my_timetable_path(event_key: @event.event_key, username: current_user.username)
    rescue URI::InvalidURIError
      false
    end

    def my_timetable_selected_date_from_referer
      query = Rack::Utils.parse_query(URI.parse(request.referer).query)
      Date.parse(query["d"]) if query["d"].present?
    rescue URI::InvalidURIError, Date::Error, TypeError
      nil
    end
end
