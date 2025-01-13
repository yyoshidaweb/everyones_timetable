class Artist < ApplicationRecord
  # nameを必須にする
  validates :name, presence: true
  belongs_to :stage
end
