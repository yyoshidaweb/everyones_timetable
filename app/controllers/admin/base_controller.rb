class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_developer!

  private

  # developer 以外は管理画面の存在を隠すため 404 にする
  def require_developer!
    raise ActiveRecord::RecordNotFound unless current_user.developer?
  end
end
