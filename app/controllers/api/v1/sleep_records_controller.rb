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
        ongoing_records = @user.sleep_records.ongoing
        ongoing_records.each do |record|
          record.update!(ended_at: Time.current)
        end

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

        render json: sleep_records, each_serializer: FollowingSleepRecordSerializer
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
