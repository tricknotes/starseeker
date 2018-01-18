FactoryBot.define do
  factory :user do
    username 'USER'
    name 'starseeker user'
    sequence(:email) {|i| "user-#{i}@starseeker.so" }
    subscribe true
    activation_state 'active'
    avatar_url 'http://example.com/avater.png'

    trait :with_authentication do
      after(:create) do |user, _evaluator|
        user.authentications.create!(attributes_for(:github))
      end
    end
  end

  factory :github, class: :authentication do
    provider 'github'
    uid 'GITHUB'
    token 'GITHUB_TOKEN'
  end
end
