module Api
  module V1
    class UsersController < BaseController
      before_action :set_follower
      before_action :set_following

      def follow
        follow = @follower.active_follows.build(following: @following)

        if follow.save
          render json: { message: "Successfully followed #{@following.name}" }, status: :created
        else
          render json: { error: follow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def unfollow
        follow = @follower.active_follows.find_by(following: @following)

        if follow
          follow.destroy
          render json: { message: "Successfully unfollowed #{@following.name}" }, status: :ok
        else
          render json: { error: "You are not following this user" }, status: :not_found
        end
      end

      private

      def set_follower
        @follower = User.find(params[:follower_id])
      end

      def set_following
        @following = User.find(params[:user_id])
      end
    end
  end
end
