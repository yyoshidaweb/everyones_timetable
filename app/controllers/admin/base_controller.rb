class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_developer!

  private

  # developer 以外は管理画面の存在を隠すため 404 にする
  def require_developer!
    return if current_user.developer?

    render file: Rails.public_path.join("404.html"), layout: false, status: :not_found
  end
end
