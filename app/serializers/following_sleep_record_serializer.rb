class FollowingSleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :user_name, :started_at, :ended_at, :duration, :duration_in_hours, :created_at

  def user_name
    object.user.name
  end

  def duration_in_hours
    "#{object.duration / 3600}h #{object.duration % 3600 / 60}m"
  end
end
