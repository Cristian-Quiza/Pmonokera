require 'rails_helper'

describe 'Customers API', type: :request do
  describe 'GET /customers/:id' do
    # Prueba 1: Retorna cliente existente con JSON correcto
    it 'devuelve cliente con customer_name, address, orders_count' do
      customer = create(:customer, name: 'Juan Pérez', address: 'Calle 123', orders_count: 3)
      
      get "/customers/#{customer.id}"
      
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['customer_name']).to eq('Juan Pérez')
      expect(json['address']).to eq('Calle 123')
      expect(json['orders_count']).to eq(3)
    end

    # Prueba 2: Retorna 404 si cliente no existe
    it 'retorna 404 si cliente no existe' do
      get '/customers/9999'
      
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to include('no encontrado')
    end

    # Prueba 3: Estructura JSON correcta
    it 'tiene estructura JSON correcta' do
      customer = create(:customer)
      
      get "/customers/#{customer.id}"
      
      json = JSON.parse(response.body)
      expect(json).to have_key('customer_name')
      expect(json).to have_key('address')
      expect(json).to have_key('orders_count')
    end

    # Prueba 4: orders_count es integer
    it 'orders_count es un número entero' do
      customer = create(:customer, orders_count: 5)
      
      get "/customers/#{customer.id}"
      
      json = JSON.parse(response.body)
      expect(json['orders_count']).to be_a(Integer)
      expect(json['orders_count']).to eq(5)
    end

    # Prueba 5: Múltiples clientes - cada uno retorna datos correctos
    it 'maneja múltiples clientes correctamente' do
      customer1 = create(:customer, name: 'Cliente 1')
      customer2 = create(:customer, name: 'Cliente 2')
      
      get "/customers/#{customer1.id}"
      json1 = JSON.parse(response.body)
      expect(json1['customer_name']).to eq('Cliente 1')
      
      get "/customers/#{customer2.id}"
      json2 = JSON.parse(response.body)
      expect(json2['customer_name']).to eq('Cliente 2')
    end
  end
end
