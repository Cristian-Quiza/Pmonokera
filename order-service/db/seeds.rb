# Seed: órdenes iniciales (solo para desarrollo)
# En producción se crean vía API POST /orders
# TODO: Implementar bulk order import desde CSV para testing

if Rails.env.development? && Order.count.zero?
  customer_ids = [1, 2, 3, 4, 5]
  products = ["Widget A", "Service B", "Product C", "License D"]

  20.times do |i|
    Order.create!(
      customer_id: customer_ids.sample,
      product_name: products.sample,
      quantity: rand(1..10),
      price: Faker::Commerce.price(range: 10..1000),
      status: ["PENDING", "COMPLETED", "CANCELLED"].sample
    )
  end
  puts "✓ Creadas #{Order.count} órdenes de prueba"
else
  puts "- Órdenes ya existen o no es environment de desarrollo"
end
