module TimetablesHelper
  # 時間（分）を行数に変換
  def duration_to_rows(minutes)
    # 5分 = 1.0remとして計算（以前は0.75rem）
    (minutes / 5.0) * 1.0
  end

  # テスト用：アーティスト表示判定
  def should_show_artist?(stage_index, hour, minute)
    # サンプルとして特定の時間にアーティストを表示
    stage_index % 4 == 0 && hour % 2 == 1 && minute == 0
  end
end
