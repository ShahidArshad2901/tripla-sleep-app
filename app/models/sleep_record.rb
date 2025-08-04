class SleepRecord < ApplicationRecord
  belongs_to :user

  # Validations
  validates :started_at, presence: true
  validate :ended_at_after_started_at, if: :ended_at?

  # Scopes
  scope :completed, -> { where.not(ended_at: nil) }
  scope :ongoing, -> { where(ended_at: nil) }
  scope :from_past_week, -> { where("started_at >= ?", 1.week.ago) }

  # Callbacks
  before_save :calculate_duration, if: :ended_at?

  private

  def ended_at_after_started_at
    return unless ended_at && started_at

    if ended_at <= started_at
      errors.add(:ended_at, "must be after started_at")
    end
  end

  def calculate_duration
    self.duration = (ended_at - started_at).to_i if started_at && ended_at
  end
end
