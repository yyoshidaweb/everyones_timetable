class StagesController < ApplicationController
  # 認証なしアクセスを許可するアクションを設定する
  allow_unauthenticated_access only: %i[ index show]
  # 複数のアクションで重複している処理を、各アクションの直前に実行する
  before_action :set_timetable, only: %i[ new create ]
  before_action :set_stage, only: %i[ show edit update destroy ]

  def index
    Stage.all
  end

  def show
  end

  def new
    @stage = @timetable.stages.new
  end

  def create
    @stage = @timetable.stages.build(stage_params)
    if @timetable.save
      redirect_to @timetable
    else
      # 保存が失敗した場合、同じフォームを再レンダリングする
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @stage.update(stage_params)
      redirect_to timetable_path(@stage.timetable)
    else
      render :edit
    end
  end

  def destroy
    @stage.destroy
    redirect_to timetable_path(@stage.timetable)
  end

  # タイムテーブルを一つ取得する
  private
  def set_timetable
    @timetable = Timetable.find(params[:timetable_id])
  end

  # ステージを一つ取得する
  private
  def set_stage
    @timetable = Stage.find(params[:id])
  end

  private
  def stage_params
    params.require(:stage).permit(:name)
  end
end
