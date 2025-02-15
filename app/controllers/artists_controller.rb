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
    Rails.logger.debug "Artist params: #{params.inspect}"
    Rails.logger.debug "Stage ID: #{params.dig(:artist, :stage_id)}"

    @stage = Stage.find(params[:artist][:stage_id])
    Rails.logger.debug "Found stage: #{@stage.inspect}"

    @artist = @stage.artists.build(artist_params)

    # 日付部分を今日の日付で補完
    @artist.start_time = Time.zone.now.to_date.to_time + @artist.start_time.seconds_since_midnight
    @artist.end_time = Time.zone.now.to_date.to_time + @artist.end_time.seconds_since_midnight

    Rails.logger.debug "Built artist: #{@artist.inspect}"

    if @artist.save
      Rails.logger.debug "Artist saved successfully"
      redirect_to timetable_path(@timetable), notice: "\u30A2\u30FC\u30C6\u30A3\u30B9\u30C8\u3092\u8FFD\u52A0\u3057\u307E\u3057\u305F"
    else
      Rails.logger.debug "Artist save failed: #{@artist.errors.full_messages}"
      @stages = Stage.where(timetable_id: params[:timetable_id])
      render :new, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Error in create: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    @stages = Stage.where(timetable_id: params[:timetable_id])
    flash.now[:alert] = "\u30A8\u30E9\u30FC\u304C\u767A\u751F\u3057\u307E\u3057\u305F"
    render :new, status: :unprocessable_entity
  end

  def edit
    @timetable = @artist.stage.timetable
    @stages = @timetable.stages
  end

  def update
    if @artist.update(artist_params)
      redirect_to timetable_path(@artist.stage.timetable), notice: "\u30A2\u30FC\u30C6\u30A3\u30B9\u30C8\u60C5\u5831\u3092\u66F4\u65B0\u3057\u307E\u3057\u305F"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    timetable = @artist.stage.timetable
    @artist.destroy
    redirect_to timetable_path(timetable), notice: "\u30A2\u30FC\u30C6\u30A3\u30B9\u30C8\u3092\u524A\u9664\u3057\u307E\u3057\u305F"
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
