class Timetable < ApplicationRecord
    # nameを必須にする
    validates :name, presence: true
end
