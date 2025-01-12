class Timetable < ApplicationRecord
    # nameを必須にする
    validates :name, presence: true
    # 説明文
    has_rich_text :description
    # 画像
    has_one_attached :image
end
