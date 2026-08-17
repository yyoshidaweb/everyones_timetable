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

  # 検索エンジンへインデックスさせないページかどうかを返す
  # 公開してよいページ以外は noindex にし、GSC の「インデックス未登録」通知を意図的な除外として扱う
  def robots_noindex?
    return true if Rails.env.staging?
    return true if defined?(@my_timetable_view) && @my_timetable_view
    return true if defined?(@event) && @event.present? && !@event.is_published?

    case "#{controller_path}##{action_name}"
    when "home#index", "static_pages#terms", "static_pages#privacy"
      false
    when "events#index"
      params[:filter].present?
    when "events#show"
      !@event.performances.exists?
    when "timetables#show"
      defined?(@performances) && @performances.blank?
    when "performers#index"
      defined?(@performers) && @performers.blank?
    when "performers#show"
      thin_performer_page?
    when "stages#index"
      defined?(@stages) && @stages.blank?
    when "stages#show"
      thin_stage_page?
    else
      true
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

  private
    # 出演情報も説明も公式サイトもない出演者詳細はソフト404になりやすい
    def thin_performer_page?
      return true unless defined?(@performer) && @performer.present?

      performances = defined?(@performances) ? @performances : []
      @performer.description.blank? && @performer.website_url.blank? && performances.blank?
    end

    # 説明も住所もないステージ詳細はソフト404になりやすい
    def thin_stage_page?
      return true unless defined?(@stage) && @stage.present?

      @stage.description.blank? && @stage.address.blank?
    end
end
