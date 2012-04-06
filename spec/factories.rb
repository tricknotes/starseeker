FactoryGirl.define do
  factory :user do
    username 'USER'
    email 'user@example.com'
    activation_state 'active'
  end

  factory :github, class: :authentication do
    provider 'github'
    uid 'GITHUB'
    token 'GITHUB_TOKEN'
  end
end
