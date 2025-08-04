source "https://rubygems.org"

gem "rails", "~> 7.2.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ mswin mswin64 mingw x64_mingw jruby ]
gem "bootsnap", require: false
gem 'active_model_serializers', '~> 0.10.14'
gem "dotenv", "~> 3.1"


group :development, :test do
  gem "debug", platforms: %i[ mri mswin mswin64 mingw x64_mingw ], require: "debug/prelude"

  gem "brakeman", require: false

  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails", "~> 6.4"
  gem "faker", "~> 3.2"

  # Debugging
  gem "pry-rails"
  gem "pry-byebug"
end

group :test do
  # Database cleaner for test isolation
  gem "database_cleaner-active_record", "~> 2.1"

  # For testing JSON responses
  gem "shoulda-matchers", "~> 6.0"
end

