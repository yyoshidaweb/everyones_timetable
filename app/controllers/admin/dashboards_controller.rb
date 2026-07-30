class Admin::DashboardsController < Admin::BaseController
  def show
    @page_title = "管理画面（開発者向け）"
    @users_count = User.count
    @users = User.order(created_at: :desc)
    @events_count = Event.count
    @events = Event.includes(:user, :event_name_tag).order(created_at: :desc)
  end
end
