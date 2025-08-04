require 'rails_helper'

RSpec.describe 'Api::V1::SleepRecords', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /api/v1/sleep_records' do
    let!(:sleep_records) { create_list(:sleep_record, 3, user: user) }

    it 'returns user sleep records ordered by created_at desc' do
      get '/api/v1/sleep_records', params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(3)
      expect(json_response.first[:id]).to eq(sleep_records.last.id)
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
    let!(:followed_user_record) { create(:sleep_record, :from_last_week, user: other_user, duration: 28800) }
    let!(:old_record) { create(:sleep_record, user: other_user, started_at: 2.weeks.ago, ended_at: 2.weeks.ago + 8.hours) }

    it 'returns sleep records of followed users from past week sorted by duration' do
      get '/api/v1/sleep_records/following', params: { user_id: user.id }

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(1)
      expect(json_response.first[:user_name]).to eq(other_user.name)
      expect(json_response.first[:duration]).to eq(28800)
    end
  end
end
