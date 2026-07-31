class NameConfirmationsController < ApplicationController
  # ユーザがログインしているかどうかを確認し、ログインしていない場合はユーザをログインページにリダイレクトする。
  before_action :authenticate_user!
  # 名前を確認済みのユーザーには表示しない
  before_action :redirect_if_name_confirmed

  def new
    # モーダル以外での表示は想定していないため、直接アクセスはトップページへ遷移させる
    return redirect_to root_path unless turbo_frame_request?

    @user = current_user
    render layout: false
  end

  def update
    @user = current_user
    # 「名前を変更する」を押した場合のみ入力された名前で更新する
    @user.name = user_params[:name] if params[:commit_type] == "change"
    # ボタンを押した時点で名前を確認済みにする
    @user.name_confirmed_at = Time.current

    if @user.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: root_path }
      end
    else
      # 入力エラーはモーダル内に表示する
      render :new, layout: false, status: :unprocessable_entity
    end
  end

  private

  def user_params
    # 許可されたパラメータのみを受け取る
    params.require(:user).permit(:name)
  end

  # 名前を確認済みならモーダルを表示する必要がないためトップページへ遷移させる
  def redirect_if_name_confirmed
    redirect_to root_path if current_user.name_confirmed?
  end
end
