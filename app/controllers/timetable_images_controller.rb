class TimetableImagesController < ApplicationController
  # 画像化用のタイムテーブルHTML断片を返す
  def capture
    case params[:type]
    when "event"
      prepare_event_capture!
    when "my-timetable"
      prepare_my_timetable_capture!
    else
      raise ActionController::RoutingError, "Not Found"
    end

    render layout: false
  end

  private
    def prepare_event_capture!
      @event = Event.find_by!(event_key: params[:event_key])
      authorize_published_event!(@event)
      @my_timetable_view = false
      load_capture_base!
      @performances = performances_for_selected_date.includes(performer: :performer_name_tag)
      @performances_by_stage = @performances.group_by(&:stage_id)
      @favorite_performance_map =
        if include_favorite_markers? && user_signed_in?
          current_user.favorite_performance_map_by_performances(@performances)
        else
          {}
        end
    end

    def prepare_my_timetable_capture!
      @event = Event.find_by!(event_key: params[:event_key])
      authorize_published_event!(@event)
      @user = User.find_by!(username: params[:username])
      @my_timetable_view = true
      load_capture_base!

      base_performances = performances_for_selected_date
      favorite_ids = @user.favorite_performance_map_by_performances(base_performances).keys
      @performances =
        if favorite_ids.empty?
          Performance.none
        else
          performances_for_selected_date.where(id: favorite_ids).includes(performer: :performer_name_tag)
        end
      @performances_by_stage = @performances.group_by(&:stage_id)
      @stages = @stages.where(id: @performances_by_stage.keys)

      @favorite_performance_map =
        if include_favorite_markers? && user_signed_in?
          current_user.favorite_performance_map_by_performances(@performances)
        else
          {}
        end
    end

    def load_capture_base!
      @days = @event.days.order(:date)
      @stages = @event.stages.order(:position).includes(:stage_name_tag)
      raise ActiveRecord::RecordNotFound if @days.blank?

      @selected_date =
        if params[:d].present?
          Date.parse(params[:d].to_s)
        else
          @days.first.date
        end

      unless @days.any? { |day| day.date == @selected_date }
        raise ActiveRecord::RecordNotFound
      end

      @include_favorite_markers = include_favorite_markers?
    end

    # favorites=0 のときだけマーカーを除外（未指定・1 は含める）
    def include_favorite_markers?
      params[:favorites].to_s != "0"
    end

    def performances_for_selected_date
      Performance
        .joins(:performer, :day, :stage)
        .where.not(start_time: nil, end_time: nil, duration: nil)
        .where(performers: { event_id: @event.id })
        .where(days: { date: @selected_date })
        .order(:start_time)
    end
end
