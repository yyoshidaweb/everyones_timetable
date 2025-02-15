class TimetablesController < ApplicationController
  # 認証なしアクセスを許可するアクションを設定する
  allow_unauthenticated_access only: %i[ index show]
  # 複数のアクションで重複している処理を、各アクションの直前に実行する
  before_action :set_timetable, only: %i[ show edit update destroy]
  # タイムテーブル一覧をビューに渡す
  def index
    @timetables = Timetable.all
  end

  # タイムテーブルを一つビューに渡す
  def show
    @timetable = Timetable.find(params[:id])
    @stages = @timetable.stages
    @artists = @timetable.artists.includes(:stage)
                        .group_by(&:stage_id)
  end

  # 新規タイムテーブル作成のフォームを作成する
  def new
    @timetable = Timetable.new
  end

  # 新規タイムテーブル作成を実行する
  def create
    @timetable = Timetable.new(timetable_params)
    # 保存を実行する
    if @timetable.save
      redirect_to @timetable
    else
      # 保存が失敗した場合、同じフォームを再レンダリングする
      render :new, status: :unprocessable_entity
    end
  end

  # 編集フォームを作成する
  def edit
  end

  # タイムテーブルの編集を実行する
  def update
    # 編集を実行する
    if @timetable.update(timetable_params)
      redirect_to @timetable
    else
      # 保存が失敗した場合、同じフォームを再レンダリングする
      render :edit, status: :unprocessable_entity
    end
  end

  # タイムテーブルを削除する
  def destroy
    @timetable.destroy
    redirect_to timetables_path
  end

  # タイムテーブルを一つ取得する
  private
  def set_timetable
    @timetable = Timetable.find(params[:id])
  end

  # 信頼できるパラメータリストのみ許可する
  private
  def timetable_params
    params.expect(timetable: [ :name, :description, :image ])
  end
end
