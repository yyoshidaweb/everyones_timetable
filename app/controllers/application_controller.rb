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

  # レイアウトの turbo-frame#modal からのリクエストかどうか。
  #
  # Turbo-Frame ヘッダーが "modal" のとき true。show/edit のモーダル描画や
  # layout: false の判定に使う。
  def modal_turbo_frame?
    turbo_frame_request_id == "modal"
  end
  helper_method :modal_turbo_frame?

  # モーダル内の編集表示・送信かどうか。
  #
  # turbo-frame#modal からの GET、または hidden field from_modal 付きの
  # PATCH/DELETE を指す。フォームの _top 送信後の再描画でも true になる。
  def modal_edit_context?
    modal_turbo_frame? || modal_form_submission?
  end
  helper_method :modal_edit_context?

  # モーダル内フォーム送信後の戻り先 URL。
  #
  # from_modal 付きの更新・削除成功時にタイムテーブル等へ戻るために使う。
  # Referer は url_from で検証し、外部 URL や不正な値は無視して
  # タイムテーブルへフォールバックする。
  def modal_return_url
    url_from(request.referer) || show_timetable_path(@event.event_key)
  end

  # 名前変更モーダルを表示するかどうかを判定するヘルパーメソッド
  def show_name_confirmation_modal?
    user_signed_in? && !current_user.name_confirmed?
  end
  helper_method :show_name_confirmation_modal?

  private
    # モーダル内編集フォームからの送信かどうか。
    #
    # フォームは turbo-frame="_top" で送るため Turbo-Frame ヘッダーは付かない。
    # hidden field from_modal でモーダル起点の送信を識別する。
    def modal_form_submission?
      params[:from_modal].present?
    end

    # モーダル内フォームのバリデーションエラー時に #modal を差し替える。
    #
    # _top 送信の 422 では通常 edit が全ページを置き換えてしまうため、
    # turbo-stream でモーダル枠だけ編集フォーム＋エラーを返す。
    def render_modal_edit_unprocessable(modal_partial)
      render turbo_stream: turbo_stream.replace("modal", partial: modal_partial),
             status: :unprocessable_entity
    end

    # 編集失敗時のレスポンスをモーダル送信か通常送信かで切り替える。
    #
    # from_modal なら render_modal_edit_unprocessable、それ以外は edit を返す。
    def render_edit_unprocessable(modal_partial)
      if modal_form_submission?
        render_modal_edit_unprocessable(modal_partial)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # 非公開イベントは作成者本人のみ閲覧を許可する
    def authorize_published_event!(event)
      return if event.viewable_by_url?
      return if user_signed_in? && event.user_id == current_user.id

      # raise だと開発環境で Exception 画面になるため、公開用404を返す
      response.set_header("X-Robots-Tag", "noindex, nofollow")
      render file: Rails.public_path.join("404.html"), status: :not_found, layout: false
    end
end
