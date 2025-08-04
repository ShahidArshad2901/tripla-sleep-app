require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:follower) { create(:user) }
  let(:following) { create(:user) }

  describe 'POST /api/v1/users/:user_id/follow' do
    it 'creates a follow relationship' do
      expect {
        post "/api/v1/users/#{following.id}/follow", params: { follower_id: follower.id }
      }.to change { Follow.count }.by(1)

      expect(response).to have_http_status(:created)
      expect(json_response[:message]).to include("Successfully followed")
    end

    context 'when already following' do
      before { create(:follow, follower: follower, following: following) }

      it 'returns error' do
        post "/api/v1/users/#{following.id}/follow", params: { follower_id: follower.id }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:error]).to include("Follower has already been taken")
      end
    end
  end

  describe 'DELETE /api/v1/users/:user_id/unfollow' do
    context 'when following exists' do
      before { create(:follow, follower: follower, following: following) }

      it 'removes the follow relationship' do
        expect {
          delete "/api/v1/users/#{following.id}/unfollow", params: { follower_id: follower.id }
        }.to change { Follow.count }.by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to include("Successfully unfollowed")
      end
    end

    context 'when not following' do
      it 'returns not found error' do
        delete "/api/v1/users/#{following.id}/unfollow", params: { follower_id: follower.id }

        expect(response).to have_http_status(:not_found)
        expect(json_response[:error]).to include("You are not following this user")
      end
    end
  end
end
