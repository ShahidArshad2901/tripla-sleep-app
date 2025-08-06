require 'rails_helper'

RSpec.describe 'Api::V1::SleepRecords', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /api/v1/sleep_records' do
    let!(:sleep_records) { create_list(:sleep_record, 25, user: user) }

    it 'returns paginated sleep records' do
      get '/api/v1/sleep_records', params: { user_id: user.id, page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)

      json_data = json_response[:data]
      expect(json_data).to be_an(Array)
      expect(json_data.size).to eq(10)

      # Check pagination meta
      expect(json_response[:meta]).to include(
        current_page: 1,
        total_pages: 3,
        total_count: 25
      )
    end

    it 'returns user sleep records ordered by created_at desc' do
      get '/api/v1/sleep_records', params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      json_data = json_response[:data]
      expect(json_data.first[:id]).to eq(sleep_records.last.id)
    end

    it 'returns 404 when user not found' do
      get '/api/v1/sleep_records', params: { user_id: 999999 }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/sleep_records/clock_in' do
    context 'when user has no ongoing sleep session' do
      it 'creates a new sleep record' do
        expect {
          post '/api/v1/sleep_records/clock_in', params: { user_id: user.id }
        }.to change { user.sleep_records.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(json_response).to be_an(Array)
        expect(json_response.first[:ended_at]).to be_nil
      end
    end

    context 'when user has an ongoing sleep session' do
      let!(:ongoing_record) { create(:sleep_record, :ongoing, user: user) }

      it 'closes the ongoing session and creates a new one' do
        expect {
          post '/api/v1/sleep_records/clock_in', params: { user_id: user.id }
        }.to change { user.sleep_records.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(ongoing_record.reload.ended_at).not_to be_nil
      end
    end
  end

  describe 'GET /api/v1/sleep_records/following' do
    let!(:follow) { create(:follow, follower: user, following: other_user) }
    let!(:followed_user_records) { create_list(:sleep_record, 30, :from_last_week, user: other_user) }

    it 'returns paginated following users sleep records' do
      get '/api/v1/sleep_records/following', params: { user_id: user.id, page: 1, per_page: 15 }

      expect(response).to have_http_status(:ok)

      json_data = json_response[:data]
      expect(json_data).to be_an(Array)
      expect(json_data.size).to eq(15)

      expect(json_response[:meta]).to include(
        current_page: 1,
        total_pages: 2,
        total_count: 30
      )
    end
  end
end
