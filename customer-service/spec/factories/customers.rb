FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "Cliente #{n}" }
    address { "Calle Principal 123, Ciudad" }
    orders_count { 0 }
  end
end
