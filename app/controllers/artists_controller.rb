class ArtistsController < ApplicationController
  # 認証なしアクセスを許可するアクションを設定する
  allow_unauthenticated_access only: %i[ index show]
  # 複数のアクションで重複している処理を、各アクションの直前に実行する
  before_action :set_stage, only: %i[ new create ]
  before_action :set_artist, only: %i[ show edit update destroy ]

  def index
    Artist.all
  end

  def new
    @artist = @stage.artists.new
  end

  def create
    @artist = @stage.artists.build(artist_params)
    if @artist.save
      redirect_to stage_path(@stage)
    else
      render :new
    end
  end

  def edit
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

  # ステージを一つ取得する
  private
  def set_stage
    @stage = Stage.find(params[:stage_id])
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
