class PerformanceFavoritesController < ApplicationController
  # ユーザがログインしているかどうかを確認し、ログインしていない場合はユーザをログインページにリダイレクトする。
  before_action :authenticate_user!

  # 出演情報お気に入り登録実行
  def create
    @performance = Performance.find(params[:performance_id])
    favorite = current_user.performance_favorites.create!(performance: @performance)
    respond_to do |format|
      format.turbo_stream do
        @favorite_performance_map = { @performance.id => favorite.id }
        render :refresh
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end

  # 出演情報お気に入り登録解除実行
  def destroy
    favorite = current_user.performance_favorites.find(params[:id])
    @performance = favorite.performance
    favorite.destroy!
    respond_to do |format|
      format.turbo_stream do
        @favorite_performance_map = {}
        render :refresh
      end
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
