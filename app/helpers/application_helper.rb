module ApplicationHelper
  # 下部タブのうちタイムテーブル以外と、その配下の詳細ページ
  TIMETABLE_CHILD_PAGES = %w[
    events#show
    performers#index
    performers#show
    stages#index
    stages#show
  ].freeze

  # Google検索のサイトリンクとして案内するページ
  SITELINK_PAGES = [
    { name: "みんなが作ったタイムテーブル", path_method: :events_path },
    { name: "利用規約", path_method: :terms_path },
    { name: "プライバシーポリシー", path_method: :privacy_path }
  ].freeze

  # 時刻を hh:mm 形式でフォーマットして返す
  def formatted_time(time)
    FestivalTime.format_clock(time)
  end

  # 正規URLを返す（クエリパラメータは除く）。content_for :canonical で上書き可能
  # タイムテーブルの ?d= など日付違いURLの重複インデックスを防ぐ
  # 概要・出演者・ステージはタイムテーブルの子なので、親のタイムテーブルへ集約する
  def canonical_url
    if content_for?(:canonical)
      content_for(:canonical)
    elsif timetable_child_page? && indexable_timetable_event?
      show_timetable_url(@event.event_key)
    else
      "#{request.base_url}#{request.path}"
    end
  end

  # サイトリンク対象ページの名称とパスを返す
  def sitelink_pages
    SITELINK_PAGES.map do |page|
      { name: page[:name], path: public_send(page[:path_method]) }
    end
  end

  # トップページ用のWebSite構造化データ（サイト名とサイトリンク対象ページ）
  def website_structured_data
    {
      "@context" => "https://schema.org",
      "@graph" => [
        {
          "@type" => "WebSite",
          "name" => "みんなのタイムテーブル",
          "alternateName" => [ "minnanotimetable" ],
          "url" => root_url
        },
        {
          "@type" => "ItemList",
          "itemListElement" => sitelink_pages.map.with_index do |page, index|
            {
              "@type" => "SiteNavigationElement",
              "position" => index + 1,
              "name" => page[:name],
              "url" => "#{request.base_url}#{page[:path]}"
            }
          end
        }
      ]
    }
  end

  # 検索エンジンへインデックスさせないページかどうかを返す
  # 子タブは noindex せず canonical で親へ集約する。ログイン・共有・編集・空のタイムテーブルなどは noindex
  def robots_noindex?
    return true if Rails.env.staging?
    return true if defined?(@my_timetable_view) && @my_timetable_view
    return true if defined?(@event) && @event.present? && !@event.search_indexable?

    case current_page
    when "home#index", "static_pages#terms", "static_pages#privacy"
      false
    when "events#index"
      params[:filter].present?
    when "timetables#show", *TIMETABLE_CHILD_PAGES
      !indexable_timetable_event?
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
    def current_page
      "#{controller_path}##{action_name}"
    end

    def timetable_child_page?
      TIMETABLE_CHILD_PAGES.include?(current_page)
    end

    # 検索の入り口になる公開タイムテーブルがあるか
    def indexable_timetable_event?
      defined?(@event) && @event.present? && @event.search_indexable? && @event.performances.exists?
    end
end
