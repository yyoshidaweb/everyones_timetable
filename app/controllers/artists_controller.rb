class ArtistsController < ApplicationController
  # 認証なしアクセスを許可するアクションを設定する
  allow_unauthenticated_access only: %i[ index show]
  # 複数のアクションで重複している処理を、各アクションの直前に実行する
  before_action :set_timetable, only: %i[ index new create ]
  before_action :set_artist, only: %i[ show edit update destroy ]

  def index
    @artist = @timetable.stages.includes(:artists).flat_map(&:artists)
  end

  def new
    @artist = Artist.new
    @stages = Stage.where(timetable_id: params[:timetable_id])
  end

  def show
  end

  def create
    # 既存ステージが存在しない場合、新しいステージを作成する
    stage = if params[:new_stage_name].present?
              Stage.create(
                timetable_id: params[:timetable_id],
                name: params[:new_stage_name]
              )
            else
              Stage.find_by(params[:artist][:stage_id])
            end
    # アーティストを作成する
    @artist = stage.artists.build(artist_params)
    if @artist.save
      redirect_to timetable_path(stage.timetable)
    else
      @stages = Stage.where(timetable_id: params[:timetable_id])
      render :new
    end
  end

  def edit
    @timetable = @artist.stage.timetable
    @stages = @timetable.stages
  end

  def update
    if @artist.update(artist_params)
      redirect_to stage_path(@artist.stage)
    else
      render :edit
    end
  end

  def destroy
    @artist.destroy
    redirect_to stage_path(@artist.stage)
  end

  # タイムテーブルを一つ取得する
  private
  def set_timetable
    @timetable = Timetable.find(params[:timetable_id])
  end

  # アーティストを一つ取得する
  private
  def set_artist
    @artist = Artist.find(params[:id])
  end

  private
  def artist_params
    params.require(:artist).permit(:name, :start_time, :end_time, :notes)
  end
end
