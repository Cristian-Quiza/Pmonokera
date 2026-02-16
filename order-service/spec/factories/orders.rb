FactoryBot.define do
  factory :order do
    sequence(:customer_id) { |n| n }
    sequence(:product_name) { |n| "Producto #{n}" }
    quantity { 1 }
    price { "99.99" }
    status { "pending" }
  end
end
