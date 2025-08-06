module Api
  module V1
    class SleepRecordsController < BaseController
      before_action :set_user, only: [ :index, :clock_in ]

      def index
        sleep_records = @user.sleep_records
                             .with_user
                             .order(created_at: :desc)
                             .limit(100) # Prevent loading too many records

        render json: sleep_records
      end

      def clock_in
        ActiveRecord::Base.transaction do
          # Close any ongoing sleep sessions
          @user.sleep_records.ongoing.update_all(ended_at: Time.current)

          # Create new sleep session
          @user.sleep_records.create!(started_at: Time.current)
        end

        # Return recent sleep records
        sleep_records = @user.sleep_records
                             .with_user
                             .order(created_at: :desc)
                             .limit(10)

        render json: sleep_records, status: :created
      end

      def following
        user = User.find(params[:user_id])

        sleep_records = SleepRecord.following_records_for_user(user)
                                   .limit(50) # Prevent too large responses

        render json: sleep_records, each_serializer: FollowingSleepRecordSerializer
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
