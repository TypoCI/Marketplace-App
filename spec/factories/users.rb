FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    password { User.new.send(:password_digest, '12345678') }
    encrypted_password { User.new.send(:password_digest, '12345678') }

    sequence :email do |n|
      "test#{n}@example.com"
    end

    after(:build) do |user|
      user.identities = build_list(:identity, 1, user: user)
    end
  end
end
