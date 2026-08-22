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

  # レイアウトのturbo-frame#modal からのリクエストかどうか
  def modal_turbo_frame?
    turbo_frame_request_id == "modal"
  end
  helper_method :modal_turbo_frame?

  # モーダル内の編集表示・送信か（turbo-frame#modal または from_modal 付き送信）
  def modal_edit_context?
    modal_turbo_frame? || modal_form_submission?
  end
  helper_method :modal_edit_context?

  # モーダル内フォーム送信後の戻り先（タイムテーブルなど元のページ）
  def modal_return_url
    url_from(request.referer) || show_timetable_path(@event.event_key)
  end

  # 名前変更モーダルを表示するかどうかを判定するヘルパーメソッド
  def show_name_confirmation_modal?
    user_signed_in? && !current_user.name_confirmed?
  end
  helper_method :show_name_confirmation_modal?

  private
    # モーダル内の編集フォームから送信されたか（turbo-frame#modal の _top 送信）
    def modal_form_submission?
      params[:from_modal].present?
    end

    # モーダル内フォームのバリデーションエラー時に #modal を差し替える
    def render_modal_edit_unprocessable(modal_partial)
      render turbo_stream: turbo_stream.replace("modal", partial: modal_partial),
             status: :unprocessable_entity
    end

    # モーダル編集の失敗時はモーダル差し替え、通常編集は edit を返す
    def render_edit_unprocessable(modal_partial)
      if modal_form_submission?
        render_modal_edit_unprocessable(modal_partial)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # 非公開イベントは作成者本人のみ閲覧を許可する
    def authorize_published_event!(event)
      return if event.is_published?
      return if user_signed_in? && event.user_id == current_user.id

      # raise だと開発環境で Exception 画面になるため、公開用404を返す
      response.set_header("X-Robots-Tag", "noindex, nofollow")
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
end
