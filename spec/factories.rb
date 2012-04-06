FactoryGirl.define do
  factory :user do
    username 'USER'
    email 'user@example.com'
    activation_state 'active'
  end
end
