# 開催日の日付境界（午前6時）を基準に、出演時刻をフェス日内の分数へ変換する
class FestivalTime
  DAY_START_HOUR = 6
  DAY_START_MINUTES = DAY_START_HOUR * 60
  MINUTES_PER_DAY = 24 * 60

  # 時計時刻をフェス日内の分に変換する（6:00=360, 0:00=1440, 5:00=1740）
  def self.to_minutes(time)
    return if time.blank?

    minutes = time.hour * 60 + time.min
    minutes < DAY_START_MINUTES ? minutes + MINUTES_PER_DAY : minutes
  end

  # 終了時刻のフェス分。開始より前なら翌日扱いとして24時間を足す
  def self.end_minutes(start_time, end_time)
    start_m = to_minutes(start_time)
    end_m = to_minutes(end_time)
    return if start_m.nil? || end_m.nil?

    end_m += MINUTES_PER_DAY if end_m < start_m
    end_m
  end

  # 開始時刻を正時に切り捨てたフェス分
  def self.floor_hour_minutes(time)
    minutes = to_minutes(time)
    return if minutes.nil?

    minutes - (minutes % 60)
  end

  # 終了時刻を次の正時に切り上げたフェス分（ちょうど正時ならそのまま）
  def self.ceil_hour_minutes(start_time, end_time)
    minutes = end_minutes(start_time, end_time)
    return if minutes.nil?
    return minutes if end_time.min.zero?

    minutes + (60 - (minutes % 60))
  end

  # フェス分から表示用の時を返す（0時過ぎは24〜29）
  def self.hour_from_minutes(minutes)
    minutes / 60
  end

  # 時計の時を表示用の時に変換する（0〜5 → 24〜29）
  def self.display_hour(hour)
    return if hour.nil?

    hour < DAY_START_HOUR ? hour + 24 : hour
  end

  # 表示用の時を時計の時に戻す（24〜29 → 0〜5）
  def self.clock_hour(hour)
    return if hour.blank?

    hour = hour.to_i
    hour >= 24 ? hour - 24 : hour
  end

  # 6時未満は +24 した hh:mm を返す
  def self.format_clock(time)
    return if time.blank?

    format("%02d:%02d", display_hour(time.hour), time.min)
  end

  # 開始正時から終了正時の直前まで、ラップする時刻スロットを返す
  def self.hour_slots(start_minutes, end_ceil_minutes)
    last_minutes = end_ceil_minutes - 60
    hours = []
    minutes = start_minutes
    while minutes <= last_minutes
      hours << hour_from_minutes(minutes)
      minutes += 60
    end
    hours
  end

  # フォームの時セレクト（6〜23 のあと 24〜29）
  def self.hour_values
    (DAY_START_HOUR...24).to_a + (24...(24 + DAY_START_HOUR)).to_a
  end

  # 6時未満を後ろに回す ORDER BY 用SQL（SQLite / PostgreSQL 両対応）
  def self.wrap_order_sql(column = "performances.start_time")
    hour_sql =
      if ApplicationRecord.connection.adapter_name == "PostgreSQL"
        "EXTRACT(HOUR FROM #{column})"
      else
        "CAST(strftime('%H', #{column}) AS INTEGER)"
      end
    Arel.sql("CASE WHEN #{hour_sql} < #{DAY_START_HOUR} THEN 1 ELSE 0 END")
  end
end
