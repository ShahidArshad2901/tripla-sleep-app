module RequestHelpers
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end

  def json_data
    json_response[:data] || json_response
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
