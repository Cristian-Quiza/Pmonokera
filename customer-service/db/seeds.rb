# Seed: Seed 10 clientes ficticios para desarrollo
# TODO: Migrar a dataset más realista desde producción
if Customer.count < 10
  10.times do |i|
    Customer.find_or_create_by(name: "#{Faker::Name.name} #{i}") do |customer|
      customer.address = Faker::Address.full_address
      customer.orders_count = rand(0..15)
    end
  end
  puts "✓ Creados #{Customer.count} clientes"
else
  puts "- Clientes ya existen. Saltando seed."
end
