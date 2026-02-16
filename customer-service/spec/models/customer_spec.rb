require 'rails_helper'

describe Customer, type: :model do
  describe 'validations' do
    # Prueba 1: Presencia del nombre
    it 'valida que name es requerido' do
      customer = Customer.new(name: nil, address: 'Calle 123')
      expect(customer.valid?).to be_falsey
      expect(customer.errors[:name]).to be_present
    end

    # Prueba 2: Presencia del address
    it 'valida que address es requerido' do
      customer = Customer.new(name: 'Juan Pérez', address: nil)
      expect(customer.valid?).to be_falsey
      expect(customer.errors[:address]).to be_present
    end

    # Prueba 3: Validación exitosa
    it 'es válido cuando name y address están presentes' do
      customer = Customer.new(
        name: 'Juan Pérez',
        address: 'Calle Principal 123'
      )
      expect(customer.valid?).to be_truthy
    end
  end

  describe 'attributes' do
    # Prueba 4: orders_count default 0
    it 'tiene orders_count default de 0' do
      customer = build(:customer)
      expect(customer.orders_count).to eq(0)
    end

    # Prueba 5: Persistencia en BD
    it 'guarda correctamente en BD' do
      customer = create(:customer, name: 'María García', address: 'Calle 45')
      
      persisted = Customer.find(customer.id)
      expect(persisted.name).to eq('María García')
      expect(persisted.address).to eq('Calle 45')
      expect(persisted.orders_count).to eq(0)
    end
  end

  describe '#as_json' do
    # Prueba 6: Serialización JSON
    it 'serializa correctamente a JSON' do
      customer = build(:customer, name: 'Test User', address: 'Test Address')
      json = customer.as_json
      
      expect(json['name']).to eq('Test User')
      expect(json['address']).to eq('Test Address')
      expect(json).to have_key('id')
    end
  end
end
