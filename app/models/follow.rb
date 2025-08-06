class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :following, class_name: "User"

  # Validations
  validates :follower_id, uniqueness: { scope: :following_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    if follower_id == following_id
      errors.add(:following_id, "can't follow yourself")
    end
  end
end
