module EventsHelper
  # Material Symbols アイコンを返す
  def material_icon(name, extra_class: nil)
    classes = [ "material-symbols-outlined", "leading-none", "shrink-0", extra_class ].compact.join(" ")
    content_tag(:span, name, class: classes, style: "font-size: 1rem;")
  end

  # 公開範囲に応じたアイコン（公開時はnilを返す）
  # align-middleはインライン文脈（一覧カード・概要ページ）用、
  # shrink-0はflex文脈（event-header）でアイコンが潰れないようにするためのもの
  def visibility_icon_for(event)
    icon_name = case event.visibility
    when "private" then "lock"
    when "unlisted" then "link"
    end
    material_icon(icon_name, extra_class: "align-middle") if icon_name
  end

  # 限定公開・非公開時は左端にアイコンを付けたタイムテーブル名を返す
  # インライン要素のみで組み立て、囲み側の`truncate`/`line-clamp`を効かせる
  def event_name_with_visibility_icon(event)
    safe_join([ visibility_icon_for(event), event.display_name ].compact, " ")
  end

  # event-headerの色のクラスを返す
  def event_header_color
    @my_timetable_view ? "bg-orange-600" : "bg-gray-800"
  end

  # event-headerのタイトルを返す（公開範囲アイコンはビュー側で先頭に付ける）
  def event_header_title
    if @my_timetable_view
      "#{@user.name}の#{@event.display_name} マイタイムテーブル"
    else
      @event.display_name
    end
  end

  # タイムテーブルとマイタイムテーブルで共有URLを分けるためのヘルパーメソッド
  def share_path_for
    if @my_timetable_view
      share_path(type: "my-timetable", event_key: @event.event_key, username: @user.username)
    else
      share_path(type: "event", event_key: @event.event_key)
    end
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
