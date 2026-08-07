# サイトマップのXMLを組み立てるサービスクラス
# Renderのコンテナはファイルシステムが揮発するため、public/には書き出さずXML文字列を返す
class SitemapBuilder
  # sitemap_generator にファイルではなくメモリ上へ書き出させるためのアダプター
  class MemoryAdapter
    attr_reader :xml

    def write(_location, raw_data)
      @xml = raw_data
    end
  end

  # host は "https://minnanotimetable.com" のようなプロトコル付きのホスト
  def self.build(host:)
    adapter = MemoryAdapter.new
    events = published_events_with_lastmod
    # トップページとイベント一覧はイベントの更新に追従して変わる
    events_lastmod = events.values.max

    SitemapGenerator::LinkSet.new(
      default_host: host,
      adapter: adapter,
      compress: false,      # gzipせずXMLのまま返す
      create_index: false,  # サイトマップは1ファイルのみ
      include_root: false,  # ルートは他の静的ページと合わせて明示的に追加する
      verbose: false        # 標準出力へのサマリー出力（ファイルサイズの取得）を止める
    ).create do
      add root_path, lastmod: events_lastmod, changefreq: "daily", priority: 1.0
      add events_path, lastmod: events_lastmod, changefreq: "daily", priority: 0.9
      # 更新日時を持たないページは lastmod を出力しない
      add terms_path, lastmod: nil, changefreq: "yearly", priority: 0.3
      add privacy_path, lastmod: nil, changefreq: "yearly", priority: 0.3

      events.each do |event, lastmod|
        add event_path(event.event_key), lastmod: lastmod, changefreq: "weekly", priority: 0.7
        add show_timetable_path(event.event_key), lastmod: lastmod, changefreq: "weekly", priority: 0.8
      end
    end

    adapter.xml
  end

  # 公開イベントをキー、最終更新日時（イベント自体と出演情報のうち新しい方）を値とするHashを返す
  def self.published_events_with_lastmod
    events = Event.where(is_published: true).order(:id).to_a
    # 出演情報を追加してもイベント自体の updated_at は変わらないため、別途取得する
    performances_updated_at = Performance
      .joins(:performer)
      .where(performers: { event_id: events.map(&:id) })
      .group("performers.event_id")
      .maximum(:updated_at)

    events.index_with do |event|
      [ event.updated_at, performances_updated_at[event.id] ].compact.max
    end
  end
  private_class_method :published_events_with_lastmod
end
