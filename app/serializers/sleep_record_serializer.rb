class SleepRecordSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :started_at, :ended_at, :duration, :created_at

  belongs_to :user

  def duration_in_hours
    "#{object.duration / 3600}h #{object.duration % 3600 / 60}m" if object.duration
  end
end
