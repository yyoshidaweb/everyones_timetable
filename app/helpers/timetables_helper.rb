module TimetablesHelper
  # 1時間あたりの高さ（rem）。時刻スロットの h-24（6rem）と一致させる
  TIMETABLE_REM_PER_HOUR = 6.0
  # タイムテーブル領域下の余白（rem）。この定数が唯一の定義（CSS変数もここから生成する）
  # 縦並びアクションボタン2つ分（各2.5rem + gap 0.5rem）に合わせて、+0.5remの余白を追加
  TIMETABLE_BOTTOM_SPACER_REM = 6.5

  # タイムテーブル全体の高さを rem で返す（1時間単位）
  def timetable_height_rem(performances)
    start_minutes, end_ceil_minutes = festival_timetable_span(performances)
    total_hours = (end_ceil_minutes - start_minutes) / 60.0
    total_hours * TIMETABLE_REM_PER_HOUR
  end

  # タイムテーブル全体の開始時刻（正時のみ取得し、分は切り捨てる）
  def timetable_start_minute
    # 最初の1回だけ計算して、1リクエスト中は結果を使い回す
    @timetable_start_minute ||= begin
      earliest = earliest_festival_performance(@performances)
      FestivalTime.floor_hour_minutes(earliest.start_time)
    end
  end

  # performance の開始位置の top を rem で返す
  def performance_top_rem(performance)
    timetable_start_min = timetable_start_minute
    start_min = FestivalTime.to_minutes(performance.start_time)
    diff_min  = start_min - timetable_start_min
    rem_per_min  = TIMETABLE_REM_PER_HOUR / 60.0
    instead_of_margin = 0.05 # マージンの代わり
    diff_min * rem_per_min + instead_of_margin
  end

  # タイムテーブル用の時刻スロット配列を生成
  def time_slots_for_timetable(performances)
    start_minutes, end_ceil_minutes = festival_timetable_span(performances)
    FestivalTime.hour_slots(start_minutes, end_ceil_minutes)
  end

  # 下余白のCSS変数を:rootへ定義するstyleタグ
  def timetable_bottom_spacer_root_style_tag
    content_tag(:style, ":root { --timetable-bottom-spacer: #{TIMETABLE_BOTTOM_SPACER_REM}rem; }")
  end

  # 表示中のイベントのオーナーかどうか
  def timetable_event_owner?
    user_signed_in? && current_user == @event.user
  end

  # ステージ列の高さスタイル（オーナーのみ下余白を含める）
  def timetable_body_col_height_style(performances)
    height = "#{timetable_height_rem(performances)}rem"
    height = "calc(#{height} + var(--timetable-bottom-spacer))" if timetable_event_owner?
    "height: #{height}"
  end

  # 下余白の開始位置に表示する正時（タイムテーブル末尾の次の時刻）
  def timetable_bottom_spacer_hour(performances)
    _start_minutes, end_ceil_minutes = festival_timetable_span(performances)
    FestivalTime.hour_from_minutes(end_ceil_minutes)
  end

  # performance の高さを rem で返す
  def performance_height_rem(performance)
    rem_per_min  = TIMETABLE_REM_PER_HOUR / 60.0
    duration_min = performance.duration
    instead_of_margin = 0.05 # マージンの代わり
    duration_min * rem_per_min - instead_of_margin
  end

  # 出演時間に応じた line-clamp クラスを返す
  def line_clamp_class_by_duration(duration)
    case duration
    when ..15 then "line-clamp-1"
    when ..20 then "line-clamp-2"
    when ..35 then "line-clamp-3"
    when ..40 then "line-clamp-4"
    when ..50 then "line-clamp-5"
    else           "line-clamp-6"
    end
  end

  # 出演時間に応じた文字サイズクラスを返す
  def font_size_class_by_duration(duration)
    case duration
    when ..5 then "text-[10px]"
    else           "text-xs"
    end
  end

  # 出演時間が5分以下の場合のみ文字を少し上に移動する
  def translate_y_by_duration(duration)
    duration <= 5 ? "-translate-y-0.5" : ""
  end

  # お気に入りの出演情報の出演者名にマーカーをつけるためのクラスを返す
  def favorite_marker(performance)
    return unless user_signed_in?
    favorite_id = @favorite_performance_map[performance.id]
    if favorite_id
      # お気に入り済み
      "favorite-marker"
    else
      # お気に入りなし
      ""
    end
  end

  # イベントに出演情報があるか判定
  def event_has_performances?
    @event_has_performances
  end

  # 画像化時のキャプチャ幅（PC風の横並びを確保）
  def timetable_image_capture_width
    min_capture_width = 1024
    stage_column_width = 120
    time_column_width = 20
    stage_count = [ @stages&.size.to_i, 1 ].max
    content_width = stage_count * stage_column_width + time_column_width

    [ min_capture_width, content_width ].max
  end

  private
    # フェス分で最も早い出演
    def earliest_festival_performance(performances)
      performances.min_by { |performance| FestivalTime.to_minutes(performance.start_time) }
    end

    # フェス分で最も遅く終わる出演
    def latest_festival_performance(performances)
      performances.max_by { |performance|
        FestivalTime.end_minutes(performance.start_time, performance.end_time)
      }
    end

    # タイムテーブルの開始正時と終了正時（排他）をフェス分で返す
    def festival_timetable_span(performances)
      earliest = earliest_festival_performance(performances)
      latest = latest_festival_performance(performances)
      [
        FestivalTime.floor_hour_minutes(earliest.start_time),
        FestivalTime.ceil_hour_minutes(latest.start_time, latest.end_time)
      ]
    end
end
