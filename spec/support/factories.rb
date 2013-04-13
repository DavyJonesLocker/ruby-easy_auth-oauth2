FactoryGirl.define do
  sequence :email do |n|
    "user-#{n}@example.com"
  end
end

FactoryGirl.define do
  factory :user do
    email
  end
end
