class User < ApplicationRecord
  # Associations
  has_many :sleep_records, dependent: :destroy

  # Following relationships
  has_many :active_follows, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_follows, class_name: "Follow", foreign_key: "following_id", dependent: :destroy

  has_many :following, through: :active_follows, source: :following
  has_many :followers, through: :passive_follows, source: :follower

  # Validations
  validates :name, presence: true

  def current_sleep_session
    sleep_records.ongoing.first
  end

  def following?(other_user)
    following.exists?(other_user.id)
  end
end
