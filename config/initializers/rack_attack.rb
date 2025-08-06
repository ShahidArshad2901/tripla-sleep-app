class Rack::Attack
  # Configure Redis cache store (fallback to memory if Redis not available)
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Throttle all requests by IP (100 requests per 5 minutes)
  throttle("req/ip", limit: 100, period: 5.minutes) do |req|
    req.ip if req.path.start_with?("/api")
  end

  # Throttle clock_in requests by user (10 requests per hour)
  throttle("clock_in/user", limit: 10, period: 1.hour) do |req|
    if req.path == "/api/v1/sleep_records/clock_in" && req.post?
      req.params["user_id"]
    end
  end

  # Custom throttle response
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    now = match_data[:epoch_time]
    headers = {
      "Content-Type" => "application/json",
      "Retry-After" => "#{match_data[:period]}",
      "X-RateLimit-Limit" => match_data[:limit].to_s,
      "X-RateLimit-Remaining" => "0",
      "X-RateLimit-Reset" => (now + match_data[:period]).to_s
    }

    [ 429, headers, [ { error: "Too many requests. Please try again later." }.to_json ] ]
  end
end

# Enable Rack::Attack
Rails.application.config.middleware.use Rack::Attack
