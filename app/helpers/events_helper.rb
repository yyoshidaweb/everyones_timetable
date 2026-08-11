module EventsHelper
  # 非公開タイムテーブル用の鍵アイコン（公開時はnilを返す）
  # align-middleはインライン文脈（一覧カード・概要ページ）用、
  # shrink-0はflex文脈（event-header）でアイコンが潰れないようにするためのもの
  def lock_icon_for(event)
    return if event.is_published?

    content_tag(
      :span,
      "lock",
      class: "material-symbols-outlined leading-none align-middle shrink-0",
      style: "font-size: 1rem;",
      data: { timetable_image_hide: true }
    )
  end

  # 非公開時は左端に鍵アイコンを付けたタイムテーブル名を返す
  # インライン要素のみで組み立て、囲み側の`truncate`/`line-clamp`を効かせる
  def event_name_with_lock(event)
    safe_join([ lock_icon_for(event), event.display_name ].compact, " ")
  end

  # event-headerの色のクラスを返す
  def event_header_color
    @my_timetable_view ? "bg-orange-600" : "bg-gray-800"
  end

  # event-headerのタイトルを返す（鍵アイコンはビュー側で先頭に付ける）
  def event_header_title
    if @my_timetable_view
      "#{@user.name}の#{@event.display_name} マイタイムテーブル"
    else
      @event.display_name
    end
  end

  # タイムテーブルとマイタイムテーブルで共有URLを分けるためのヘルパーメソッド
  def share_path_for
    options = if @my_timetable_view
      { type: "my-timetable", event_key: @event.event_key, username: @user.username }
    else
      { type: "event", event_key: @event.event_key }
    end
    # 表示中の日付を渡し、画像ファイル名に使う
    options[:d] = @selected_date if @selected_date.present?
    share_path(options)
  end

  # 作成したタイムテーブル一覧かどうか判定する
  def created?
    params[:filter] == "created"
  end

  # お気に入りのタイムテーブル一覧かどうか判定する
  def favorites?
    params[:filter] == "favorites"
  end
end
