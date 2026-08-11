module TimetablesHelper
  # 1時間あたりの高さ（rem）。時刻スロットの h-24（6rem）と一致させる
  TIMETABLE_REM_PER_HOUR = 6.0
  # タイムテーブル領域下の余白（rem）。この定数が唯一の定義（CSS変数もここから生成する）
  # 縦並びアクションボタン2つ分（各2.5rem + gap 0.5rem）に合わせて、+0.5remの余白を追加
  TIMETABLE_BOTTOM_SPACER_REM = 6.5

  # タイムテーブル全体の高さを rem で返す（1時間単位）
  def timetable_height_rem(performances)
    start_hour = performances.min_by(&:start_time).start_time.hour
    end_time   = performances.max_by(&:end_time).end_time
    # 終了時刻は「次の時間」に切り上げ
    end_hour = end_time.min.zero? ? end_time.hour : end_time.hour + 1
    total_hours = end_hour - start_hour
    total_hours * TIMETABLE_REM_PER_HOUR
  end

  # タイムテーブル全体の開始時刻（正時のみ取得し、分は切り捨てる）
  def timetable_start_minute
    # 最初の1回だけ計算して、1リクエスト中は結果を使い回す
    @timetable_start_minute ||= begin
      earliest = @performances.min_by(&:start_time).start_time
      # タイムテーブル描画開始位置を正時にするため、minuteを切り捨てる
      earliest.hour * 60
    end
  end

  # performance の開始位置の top を rem で返す
  def performance_top_rem(performance)
    timetable_start_min = timetable_start_minute
    start_min = performance.start_time.hour * 60 + performance.start_time.min
    diff_min  = start_min - timetable_start_min
    rem_per_min  = TIMETABLE_REM_PER_HOUR / 60.0
    instead_of_margin = 0.05 # マージンの代わり
    diff_min * rem_per_min + instead_of_margin
  end

  # タイムテーブル用の時刻スロット配列を生成
  def time_slots_for_timetable(performances)
    start_time = performances.min_by(&:start_time).start_time
    end_time   = performances.max_by(&:end_time).end_time
    start_hour = start_time.hour
    # 終了時刻が00分なら、その時間は表示しない
    last_hour =
      if end_time.min.zero?
        end_time.hour - 1
      else
        end_time.hour
      end
    (start_hour..last_hour).to_a
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
    end_time = performances.max_by(&:end_time).end_time
    end_hour = end_time.min.zero? ? end_time.hour : end_time.hour + 1
    end_hour % 24
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
    stage_count = [ @stages&.size.to_i, 1 ].max
    [ 1024, stage_count * 120 + 20 ].max
  end
end
