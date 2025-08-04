FactoryBot.define do
  factory :sleep_record do
    user
    started_at { 8.hours.ago }
    ended_at { 1.hour.ago }

    trait :ongoing do
      ended_at { nil }
      duration { nil }
    end

    trait :completed do
      started_at { 10.hours.ago }
      ended_at { 2.hours.ago }
    end

    trait :from_last_week do
      started_at { 5.days.ago }
      ended_at { 5.days.ago + 8.hours }
    end
  end
end
