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
  def timetable_image_filename
    date_str = timetable_image_date_str
    case params[:type]
    when "event"
      "#{safe_filename_component(@event.display_name)}_#{date_str}.png"
    when "my-timetable"
      "#{safe_filename_component(@user.name)}の#{safe_filename_component(@event.display_name)}マイタイムテーブル_#{date_str}.png"
    end
  end

  # 画像ファイル名用の日付（MMDD）
  def timetable_image_date_str
    date = params[:d].present? ? Date.parse(params[:d].to_s) : Date.current
    date.strftime("%m%d")
  rescue Date::Error, ArgumentError
    Date.current.strftime("%m%d")
  end

  # ファイル名に使えない文字を置換する
  def safe_filename_component(value)
    value.to_s.gsub(%r{[\\/:*?"<>|]}, "_").strip
  end
end
