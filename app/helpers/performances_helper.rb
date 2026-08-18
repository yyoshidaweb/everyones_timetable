module PerformancesHelper
  # 5分刻みの時刻スロットを生成（時は6時始まりで、0時過ぎは24〜29）
  def time_select_options(hour_step: 1, minute_step: 5)
    {
      hours: FestivalTime.hour_values.each_slice(hour_step).map(&:first).map { |h| [ format("%02d", h), h ] },
      minutes: (0...60).step(minute_step).map { |m| [ format("%02d", m), m ] }
    }
  end

  # durationスロットを生成
  def duration_select_options(step: 5, min: 5, max: 120)
    (min..max).step(step)
  end
end
