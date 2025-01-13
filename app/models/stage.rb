class Stage < ApplicationRecord
  belongs_to :timetable
  has_many :artists, dependent: destroy
end
