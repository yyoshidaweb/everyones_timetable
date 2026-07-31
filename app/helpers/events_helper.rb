module EventsHelper
  # 非公開タイムテーブル用の鍵アイコン
  def lock_icon
    content_tag(
      :span,
      "lock",
      class: "material-symbols-outlined leading-none",
      style: "font-size: 1rem;"
    )
  end

  # 非公開時は左端に鍵アイコンを付けたタイムテーブル名を返す
  def event_name_with_lock(event)
    return event.display_name if event.is_published?

    content_tag(:span, class: "inline-flex items-center gap-1 align-middle leading-none") do
      safe_join([ lock_icon, event.display_name ], " ")
    end
  end

  # event-headerの色のクラスを返す
  def event_header_color
    @my_timetable_view ? "bg-orange-600" : "bg-gray-800"
  end

  # event-headerのタイトルを返す
  def event_header_title
    if @my_timetable_view
      safe_join([ "#{@user.name}の", event_name_with_lock(@event), " マイタイムテーブル" ])
    else
      event_name_with_lock(@event)
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
