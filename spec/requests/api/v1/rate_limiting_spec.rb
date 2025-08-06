require 'rails_helper'

RSpec.describe 'Rate Limiting', type: :request do
  let(:user) { create(:user) }

  before do
    # Reset Rack::Attack cache before each test
    Rack::Attack.cache.store.clear
  end

  describe 'general API rate limiting' do
    it 'throttles requests after limit is reached' do
      # Make 100 requests (the limit)
      100.times do
        get '/api/v1/sleep_records', params: { user_id: user.id }
        expect(response).not_to have_http_status(:too_many_requests)
      end

      # 101st request should be throttled
      get '/api/v1/sleep_records', params: { user_id: user.id }
      expect(response).to have_http_status(:too_many_requests)
      expect(json_response[:error]).to include('Too many requests')
    end
  end

  describe 'clock_in rate limiting' do
    it 'throttles clock_in requests per user' do
      # Make 10 requests (the limit)
      10.times do
        post '/api/v1/sleep_records/clock_in', params: { user_id: user.id }
        expect(response).not_to have_http_status(:too_many_requests)
      end

      # 11th request should be throttled
      post '/api/v1/sleep_records/clock_in', params: { user_id: user.id }
      expect(response).to have_http_status(:too_many_requests)
    end
  end
end
