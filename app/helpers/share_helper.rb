module ShareHelper
  # 共有用のURLを返す
  def share_url_for
    case params[:type]
    when "event"
      show_timetable_url(@event.event_key)
    when "my-timetable"
      show_my_timetable_url(@event.event_key, @user.username)
    end
  end

  # 共有用のページタイトルを返す
  def share_page_title_for
    case params[:type]
    when "event"
      "タイムテーブルを共有"
    when "my-timetable"
      "マイタイムテーブルを共有"
    end
  end

  # ページタイトルのマーカーを返す
  def share_page_title_marker
    case params[:type]
    when "event"
      "share-timetable-marker"
    when "my-timetable"
      "favorite-marker"
    end
  end

  # 共有用のタイトルを返す
  def share_title_for
    case params[:type]
    when "event"
      "#{@event.display_name} タイムテーブル"
    when "my-timetable"
      "#{@user.name}の#{@event.display_name} マイタイムテーブル"
    end
  end

  # X共有用のテキストを返す
  def share_text_for
    "#{share_title_for}\n\n#{share_url_for}\n\n#みんなのタイムテーブル | 音楽フェスのタイムテーブルを作ろう！"
  end

  # 共有モーダルのborderを返す
  def share_modal_border
    case params[:type]
    when "event"
      ""
    when "my-timetable"
      "ring-6 ring-orange-400"
    end
  end

  # タイムテーブル画像のダウンロードファイル名を返す
  def timetable_image_filename(date: nil)
    date_str = timetable_image_date_str(date)
    case params[:type]
    when "event"
      "#{@event.event_key}_#{date_str}.png"
    when "my-timetable"
      "#{@event.event_key}_#{@user.username}_#{date_str}.png"
    end
  end

  # 日付部分を差し替える用のファイル名テンプレート（DATE が MMDD に置換される）
  def timetable_image_filename_template
    timetable_image_filename(date: Date.new(2000, 1, 1)).sub("_0101.png", "_DATE.png")
  end

  # 画像キャプチャ用HTMLのパス
  def timetable_image_capture_path_for
    case params[:type]
    when "event"
      timetable_image_capture_path(type: "event", event_key: @event.event_key)
    when "my-timetable"
      timetable_image_capture_path(type: "my-timetable", event_key: @event.event_key, username: @user.username)
    end
  end

  # 日付選択肢（モーダル用）
  def timetable_image_day_options
    Array(@days).map do |day|
      {
        date: day.date.iso8601,
        label: day.date.strftime("%-m/%-d"),
        filename: timetable_image_filename(date: day.date)
      }
    end
  end

  # 画像ファイル名用の日付（MMDD）
  def timetable_image_date_str(date = nil)
    resolved =
      if date.present?
        date
      elsif params[:d].present?
        Date.parse(params[:d].to_s)
      else
        Date.current
      end
    resolved.strftime("%m%d")
  rescue Date::Error, ArgumentError
    Date.current.strftime("%m%d")
  end

end
