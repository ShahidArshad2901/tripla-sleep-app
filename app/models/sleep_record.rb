class SleepRecord < ApplicationRecord
  belongs_to :user

  # Validations
  validates :started_at, presence: true
  validate :ended_at_after_started_at, if: :ended_at?

  # Scopes
  scope :completed, -> { where.not(ended_at: nil) }
  scope :ongoing, -> { where(ended_at: nil) }
  scope :from_past_week, -> { where("started_at >= ?", 1.week.ago) }
  scope :ordered_by_duration, -> { order(duration: :desc) }
  scope :with_user, -> { includes(:user) }

  # Callbacks
  before_save :calculate_duration

  # Class methods for optimized queries
  def self.following_records_for_user(user)
    joins(:user)
      .where(user: user.following)
      .from_past_week
      .completed
      .ordered_by_duration
      .with_user
  end

  private

  def ended_at_after_started_at
    return unless ended_at && started_at

    if ended_at <= started_at
      errors.add(:ended_at, "must be after started_at")
    end
  end

  def calculate_duration
    if started_at && ended_at
      self.duration = (ended_at - started_at).to_i
    else
      self.duration = nil
    end
  end
end
