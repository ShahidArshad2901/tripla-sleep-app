module Api
  module V1
    class SleepRecordsController < BaseController
      before_action :set_user, only: [ :index, :clock_in ]

      # GET /api/v1/sleep_records
      def index
        sleep_records = @user.sleep_records
                             .with_user
                             .order(created_at: :desc)
                             .page(page_params[:page])
                             .per(page_params[:per_page])

        render json: {
          data: ActiveModelSerializers::SerializableResource.new(
            sleep_records,
            each_serializer: SleepRecordSerializer
          ).as_json,
          meta: pagination_meta(sleep_records)
        }
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
                                   .page(page_params[:page])
                                   .per(page_params[:per_page])

        render json: {
          data: ActiveModelSerializers::SerializableResource.new(
            sleep_records,
            each_serializer: FollowingSleepRecordSerializer
          ).as_json,
          meta: pagination_meta(sleep_records)
        }
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end
    end
  end
end
