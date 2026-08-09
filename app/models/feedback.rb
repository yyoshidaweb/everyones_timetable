class Feedback < ApplicationRecord
  belongs_to :user, optional: true

  validates :body, presence: true, length: { maximum: 2000 }
end
