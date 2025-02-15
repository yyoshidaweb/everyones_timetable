class Artist < ApplicationRecord
  # nameを必須にする
  validates :name, presence: true
  belongs_to :stage

  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "は開始時間より後の時間を指定してください")
    end
  end
end
