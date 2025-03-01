class Timetable < ApplicationRecord
    # nameを必須にする
    validates :name, presence: true
    has_many :stages, dependent: :destroy
    has_many :artists, through: :stages
end
