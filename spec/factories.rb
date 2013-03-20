FactoryGirl.define do
  factory :user do
    username 'USER'
    name 'starseeker user'
    sequence(:email) {|i| "user-#{i}@starseeker.so" }
    subscribe true
    activation_state 'active'
  end

  factory :github, class: :authentication do
    provider 'github'
    uid 'GITHUB'
    token 'GITHUB_TOKEN'
  end
end
