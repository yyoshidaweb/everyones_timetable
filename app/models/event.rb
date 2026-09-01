class Event < ApplicationRecord
  # イベントは一つのユーザーに属する
  belongs_to :user
  # イベントは一つのイベント名タグに属する
  belongs_to :event_name_tag

  # 関連
  has_many :days, dependent: :destroy
  has_many :stages, -> { order(:position) }, dependent: :destroy
  has_many :performers, dependent: :destroy
  # 多対多
  has_many :performances, through: :days
  has_many :event_favorites, dependent: :destroy

  # イベントをお気に入り登録しているユーザーの一覧を取得したいときに使うエイリアス
  has_many :favorited_users, through: :event_favorites, source: :user

  # nested attributes を許可（フォームで fields_for を使うため）
  accepts_nested_attributes_for :event_name_tag, update_only: false

  enum :visibility, {
    public: 0,
    unlisted: 1,
    private: 2
  }, prefix: true

  # ===== バリデーション =====
  validates :event_key, presence: true, uniqueness: true
  validates :event_name_tag, presence: true
  validates_associated :event_name_tag # event_name_tag のバリデーションエラーを event.errors に自動で伝播させる

  # 1ユーザー内のイベント名はユニーク
  validates :event_name_tag, presence: true, uniqueness: { scope: :user_id }

  # みんなが作ったタイムテーブルのうち、未来イベントを取得
  scope :future_all, -> {
    now = Time.current.to_date
    visibility_public
      .left_joins(:event_favorites)
      .left_joins(performers: :performances)
      .left_joins(:days)
      .includes(:user, :days, :event_name_tag, :event_favorites)
      .group(:id)
      .having("MAX(days.date) >= ?", now)
      .order(
        Arel.sql("CASE WHEN MAX(days.date) >= '#{now}' THEN MAX(days.date) END ASC"), # 現在日付に近い順
        Arel.sql("COUNT(DISTINCT event_favorites.id) DESC"), # お気に入り数の多い順
        Arel.sql("COUNT(DISTINCT performances.id) DESC"), # 出演情報の多い順
        created_at: :desc # 作成日の降順
      )
      .limit(100) # 取得上限
  }

  # みんなが作ったタイムテーブルのうち、過去イベントを取得
  scope :past_all, -> {
    now = Time.current.to_date
    visibility_public
      .left_joins(:event_favorites)
      .left_joins(performers: :performances)
      .left_joins(:days)
      .includes(:user, :days, :event_name_tag, :event_favorites)
      .group(:id)
      .having("MAX(days.date) < ?", now)
      .order(
        Arel.sql("CASE WHEN MAX(days.date) < '#{now}' THEN MAX(days.date) END DESC"), # 現在日付に近い順
        Arel.sql("COUNT(DISTINCT event_favorites.id) DESC"), # お気に入り数の多い順
        Arel.sql("COUNT(DISTINCT performances.id) DESC"), # 出演情報の多い順
        created_at: :desc # 作成日の降順
      )
      .limit(100) # 取得上限
  }

  # トップページ用にみんなが作ったタイムテーブルを取得
  scope :popular_for_home, -> {
    popular_for_all.limit(20)
  }

  # 作成したタイムテーブル
  scope :recent_created_by, ->(user) {
    where(user: user)
      .includes(:user, :days, :event_name_tag, :event_favorites)
      .order(created_at: :desc)
  }

  # トップページ用に作成したタイムテーブルを取得
  scope :recent_created_for_home, ->(user) {
    recent_created_by(user).limit(3)
  }

  # お気に入りタイムテーブル（最後にお気に入りした順）
  # 非公開イベントは作成者本人のお気に入り一覧にのみ表示する
  scope :recent_favorite_by, ->(user) {
    joins(:event_favorites)
      .where(event_favorites: { user_id: user.id })
      .where("events.visibility != ? OR events.user_id = ?", visibilities[:private], user.id)
      .includes(:user, :days, :event_name_tag, :event_favorites)
      .order("event_favorites.created_at DESC")
  }

  # トップページ用にお気に入りタイムテーブルを取得
  scope :recent_favorite_for_home, ->(user) {
    recent_favorite_by(user).limit(3)
  }

  # フォームや一覧表示用の名前
  def display_name
    event_name_tag.name
  end

  # URLを知っていれば閲覧可能かどうか
  def viewable_by_url?
    !visibility_private?
  end

  # 検索エンジンへのインデックス対象かどうか
  def search_indexable?
    visibility_public?
  end
end
