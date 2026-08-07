class SitemapsController < ApplicationController
  # 毎リクエストで全イベントを走査しないよう、生成したXMLを一定時間キャッシュする
  CACHE_EXPIRES_IN = 1.hour

  def show
    xml = Rails.cache.fetch("sitemap/#{request.base_url}", expires_in: CACHE_EXPIRES_IN) do
      SitemapBuilder.build(host: request.base_url)
    end

    render xml: xml
  end
end
