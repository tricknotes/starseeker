FactoryGirl.define do
  factory :user do
    username 'USER'
    name 'starseeker'
    email 'user@example.com'
    activation_state 'active'
  end

  factory :github, class: :authentication do
    provider 'github'
    uid 'GITHUB'
    token 'GITHUB_TOKEN'
  end
end
