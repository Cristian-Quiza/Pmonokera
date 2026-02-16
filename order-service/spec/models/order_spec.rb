require 'rails_helper'

describe Order, type: :model do
  describe 'validations' do
    # Prueba 1: customer_id es requerido
    it 'valida que customer_id es requerido' do
      order = Order.new(
        customer_id: nil,
        product_name: 'Café',
        quantity: 1,
        price: 15000
      )
      expect(order.valid?).to be_falsey
      expect(order.errors[:customer_id]).to be_present
    end

    # Prueba 2: product_name es requerido
    it 'valida que product_name es requerido' do
      order = Order.new(
        customer_id: 1,
        product_name: nil,
        quantity: 1,
        price: 15000
      )
      expect(order.valid?).to be_falsey
      expect(order.errors[:product_name]).to be_present
    end

    # Prueba 3: quantity > 0
    it 'valida que quantity es mayor a 0' do
      order = Order.new(
        customer_id: 1,
        product_name: 'Café',
        quantity: 0,
        price: 15000
      )
      expect(order.valid?).to be_falsey
      expect(order.errors[:quantity]).to be_present
    end

    # Prueba 4: quantity negativo es inválido
    it 'rechaza quantity negativo' do
      order = Order.new(
        customer_id: 1,
        product_name: 'Café',
        quantity: -5,
        price: 15000
      )
      expect(order.valid?).to be_falsey
    end

    # Prueba 5: price > 0
    it 'valida que price es mayor a 0' do
      order = Order.new(
        customer_id: 1,
        product_name: 'Café',
        quantity: 2,
        price: 0
      )
      expect(order.valid?).to be_falsey
      expect(order.errors[:price]).to be_present
    end

    # Prueba 6: Validación exitosa
    it 'es válida cuando todos los campos son correctos' do
      order = Order.new(
        customer_id: 1,
        product_name: 'Café Juan Valdez',
        quantity: 2,
        price: 15000,
        status: 'pending'
      )
      expect(order.valid?).to be_truthy
    end
  end

  describe 'attributes' do
    # Prueba 7: Persistencia en BD
    it 'guarda correctamente en BD' do
      order = create(:order,
        customer_id: 1,
        product_name: 'Teclado Mecanico',
        quantity: 3,
        price: 20000
      )
      
      persisted = Order.find(order.id)
      expect(persisted.customer_id).to eq(1)
      expect(persisted.product_name).to eq('Teclado Mecanico')
      expect(persisted.quantity).to eq(3)
      expect(persisted.price.to_s).to match(/^2e5|^20000/)  # Puede ser decimal o string
    end

    # Prueba 8: Status default
    it 'tiene status por defecto pending si no se especifica' do
      order = create(:order)
      expect(order.status).to eq('pending')
    end

    # Prueba 9: Timestamp created_at
    it 'registra created_at automáticamente' do
      order = create(:order)
      expect(order.created_at).to be_present
      expect(order.created_at).to be_a(Time)
    end
  end

  describe '#as_json' do
    # Prueba 10: Serialización JSON
    it 'serializa correctamente a JSON' do
      order = build(:order,
        customer_id: 1,
        product_name: 'Producto Test'
      )
      json = order.as_json
      
      expect(json['customer_id']).to eq(1)
      expect(json['product_name']).to eq('Producto Test')
      expect(json).to have_key('id')
      expect(json).to have_key('created_at')
    end
  end
end
