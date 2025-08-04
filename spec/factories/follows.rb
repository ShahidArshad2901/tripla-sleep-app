FactoryBot.define do
  factory :follow do
    follower { association :user }
    following { association :user }
  end
end
