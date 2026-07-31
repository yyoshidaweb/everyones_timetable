class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  unless Rails.env.development?
      # 本番・ステージングでのみ最新ブラウザのみ許可
      allow_browser versions: :modern
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # 未ログイン時はログイン画面ではなくトップページへリダイレクトされるようにオーバーライド
  def authenticate_user!
    unless user_signed_in?
      redirect_to root_path
    else
      super
    end
  end

  # ログイン後のリダイレクト先の指定をオーバーライド
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  # プレビュー環境かどうかを判定するヘルパーメソッド
  def self.preview_environment?
    Rails.env.production? && ENV["IS_PULL_REQUEST"] == "true"
  end

  # インスタンスメソッドとしてもpreview_environment?を使用できるようにする
  def preview_environment?
    self.class.preview_environment?
  end
  # ビューでpreview_environment?メソッドを使用できるようにする
  helper_method :preview_environment?

  private
    # 非公開イベントは作成者本人のみ閲覧を許可する
    def authorize_published_event!(event)
      return if event.is_published?
      return if user_signed_in? && event.user_id == current_user.id

      # raise だと開発環境で Exception 画面になるため、公開用404を返す
      response.set_header("X-Robots-Tag", "noindex, nofollow")
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
end
