class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # 開発中はコメントアウトしておく（最新ブラウザのみを許可する設定）
  # allow_browser versions: :modern

  # ロケールを変更する
  around_action :switch_locale
  # パラメータに応じてロケールを変更する
  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end
end
