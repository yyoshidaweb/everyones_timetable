class SitemapsController < ApplicationController
  def show
    # Solid Cache（solid_cache_entries）が未整備のため Rails.cache は使わず都度生成する
    xml = SitemapBuilder.build(host: request.base_url)
    render xml: xml
  end
end
