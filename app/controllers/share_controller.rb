class ShareController < ApplicationController
  def show
    case params[:type]
    when "event"
      @event = Event.find_by!(event_key: params[:event_key])
      authorize_published_event!(@event)
      render layout: false if turbo_frame_request?
    when "my-timetable"
      @event = Event.find_by!(event_key: params[:event_key])
      authorize_published_event!(@event)
      @user = User.find_by!(username: params[:username])
      render layout: false if turbo_frame_request?
    else
      # 共有URLのtypeパラメータが不正な場合は404 Not Foundを返す
      raise ActionController::RoutingError, "Not Found"
    end
  end
end
