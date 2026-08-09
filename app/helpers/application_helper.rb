module ApplicationHelper
  # 時刻を hh:mm 形式でフォーマットして返す
  def formatted_time(time)
    time&.strftime("%H:%M")
  end

  # 正規URLを返す（クエリパラメータは除く）。content_for :canonical で上書き可能
  # タイムテーブルの ?d= など日付違いURLの重複インデックスを防ぐ
  def canonical_url
    if content_for?(:canonical)
      content_for(:canonical)
    else
      "#{request.base_url}#{request.path}"
    end
  end

  # body要素のクラスを返す
  # タイムテーブル画面はページ全体スクロールを止め、内側コンテナのみスクロールさせる
  def body_element_class
    if defined?(@timetable_view) && @timetable_view
      "h-svh flex flex-col overflow-hidden"
    else
      "min-h-svh flex flex-col"
    end
  end

  # main要素のクラスを返す
  def main_element_class
    if defined?(@timetable_view) && @timetable_view
      "min-h-0 flex-1 overflow-hidden"
    elsif defined?(@show_event_header) && @show_event_header
      "m-2 pt-24"
    elsif defined?(@page_title) && @page_title.present?
      "m-2 pt-16"
    else
      "m-2 pt-8"
    end
  end

  # text内にリンクが含まれていたら自動リンク化する
  def auto_link_text(text)
    return "" if text.blank?
    # URLをリンク化し、XSSを防ぐ
    linked = Rinku.auto_link(
      text,
      :urls,
      'target="_blank" rel="noopener"
      class="text-blue-600 underline hover:text-blue-800 break-all"'
    )
    sanitized = sanitize(
      linked,
      tags: %w[a br],
      attributes: %w[href target rel class]
    )
    content_tag(:p, sanitized.html_safe.html_safe, class: "text-gray-800 whitespace-pre-line")
  end
end
