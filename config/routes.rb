Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Sleep records routes
      get "sleep_records", to: "sleep_records#index"
      post "sleep_records/clock_in", to: "sleep_records#clock_in"
      get "sleep_records/following", to: "sleep_records#following"

      # User follow/unfollow routes
      post "users/:user_id/follow", to: "users#follow"
      delete "users/:user_id/unfollow", to: "users#unfollow"
    end
  end
end
