module Api
  module V1
    class SleepRecordsController < BaseController
      before_action :set_user, only: [ :index, :clock_in ]

      def index
        sleep_records = @user.sleep_records.order(created_at: :desc)
        render json: sleep_records
      end

      def clock_in
        # Close any ongoing sleep sessions
        @user.sleep_records.ongoing.update_all(ended_at: Time.current)

        # Create new sleep session
        @user.sleep_records.create!(started_at: Time.current)

        # Return all sleep records ordered by created_at
        sleep_records = @user.sleep_records.order(created_at: :desc)
        render json: sleep_records, status: :created
      end

      def following
        user = User.find(params[:user_id])

        # Get sleep records from followed users from the past week
        sleep_records = SleepRecord
          .joins(:user)
          .where(user: user.following)
          .from_past_week
          .completed
          .order(duration: :desc)
          .includes(:user)

        render json: format_following_sleep_records(sleep_records)
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def format_following_sleep_records(records)
        records.map do |record|
          {
            id: record.id,
            user_id: record.user_id,
            user_name: record.user.name,
            started_at: record.started_at,
            ended_at: record.ended_at,
            duration: record.duration,
            created_at: record.created_at
          }
        end
      end
    end
  end
end
