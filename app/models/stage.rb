class Stage < ApplicationRecord
  # nameを必須にする
  validates :name, presence: true
  belongs_to :timetable
  has_many :artists
end
