FactoryBot.define do
  factory :customer do
    name { "MyString" }
    address { "MyString" }
    orders_count { 1 }
  end
end
