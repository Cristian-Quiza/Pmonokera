# Clientes predefinidos (base fija, no crear nuevos vía API).
# Idempotente: find_or_create_by evita duplicados al ejecutar db:seed varias veces.
[
  { name: "Juan Pérez Gómez", address: "Cra 7 #123-45, Bogotá D.C.", orders_count: 0 },
  { name: "María López Ramírez", address: "Cl 45 #12-34, Medellín", orders_count: 0 },
  { name: "Carlos Andrés Ruiz", address: "Av. Calle 26 #68-35, Bogotá", orders_count: 0 },
  { name: "Ana María Torres", address: "Calle 5 #23-67, Cali", orders_count: 0 },
  { name: "Luis Fernando Castro", address: "Carrera 50 #80-90, Barranquilla", orders_count: 0 }
].each do |attrs|
  Customer.find_or_create_by!(name: attrs[:name]) do |c|
    c.address = attrs[:address]
    c.orders_count = attrs[:orders_count]
  end
end
