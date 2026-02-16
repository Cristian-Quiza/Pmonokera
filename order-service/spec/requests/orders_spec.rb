require 'rails_helper'

describe 'Orders API', type: :request do
  describe 'POST /orders' do
    # Prueba 1: Crea orden exitosamente si cliente existe (mockea Faraday 200)
    it 'crea orden si cliente existe en customer-service' do
      # Mock: Faraday retorna 200 (cliente existe)
      allow_any_instance_of(Faraday::Connection)
        .to receive(:get).and_return(double(status: 200))

      post '/orders', params: {
        order: {
          customer_id: 1,
          product_name: 'Café Juan Valdez',
          quantity: 2,
          price: 15000,
          status: 'pending'
        }
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['customer_id']).to eq(1)
      expect(json['product_name']).to eq('Café Juan Valdez')
      expect(json['quantity']).to eq(2)
      # Price puede venir como string con .0 o como notación científica
      expect(json['price'].to_s).to match(/^15000|^1\.5e\+04/)
    end

    # Prueba 2: Retorna 404 si cliente NO existe en customer-service
    it 'retorna 404 si cliente no existe en customer-service' do
      # Mock: Faraday retorna 404 (cliente no encontrado)
      allow_any_instance_of(Faraday::Connection)
        .to receive(:get).and_return(double(status: 404))

      post '/orders', params: {
        order: {
          customer_id: 9999,
          product_name: 'Producto',
          quantity: 1,
          price: 100,
          status: 'pending'
        }
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to include('no encontrado')
    end

    # Prueba 3: Valida que customer_id es requerido
    it 'valida que customer_id es requerido' do
      post '/orders', params: {
        order: {
          customer_id: nil,
          product_name: 'Producto',
          quantity: 1,
          price: 100
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to include('customer_id')
    end

    # Prueba 4: Valida que todos los parámetros se guardan correctamente
    it 'persiste todos los parámetros correctamente' do
      allow_any_instance_of(Faraday::Connection)
        .to receive(:get).and_return(double(status: 200))

      post '/orders', params: {
        order: {
          customer_id: 2,
          product_name: 'Teclado Mecánico RGB',
          quantity: 3,
          price: 20000,
          status: 'confirmed'
        }
      }

      order = Order.last
      expect(order.customer_id).to eq(2)
      expect(order.product_name).to eq('Teclado Mecánico RGB')
      expect(order.quantity).to eq(3)
      # Price puede ser decimal, string, o notación científica
      expect(order.price.to_s).to match(/^20000|^2e5/)
      expect(order.status).to eq('confirmed')
    end

    # Prueba 5: Retorna JSON con orden creada
    it 'retorna JSON de la orden creada' do
      allow_any_instance_of(Faraday::Connection)
        .to receive(:get).and_return(double(status: 200))

      post '/orders', params: {
        order: {
          customer_id: 1,
          product_name: 'iPhone 17',
          quantity: 1,
          price: 7000000,
          status: 'pending'
        }
      }

      json = JSON.parse(response.body)
      expect(json).to have_key('id')
      expect(json).to have_key('created_at')
      expect(json['product_name']).to eq('iPhone 17')
    end
  end

  describe 'GET /orders' do
    # Prueba 6: Retorna todas las órdenes
    it 'retorna todas las órdenes' do
      create(:order, customer_id: 1)
      create(:order, customer_id: 2)

      get '/orders'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
    end

    # Prueba 7: Filtra órdenes por customer_id
    it 'filtra órdenes por customer_id' do
      create(:order, customer_id: 1)
      create(:order, customer_id: 2)

      get '/orders?customer_id=1'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json[0]['customer_id']).to eq(1)
    end

    # Prueba 8: Retorna Array vacío si no hay órdenes
    it 'retorna array vacío si no hay órdenes' do
      get '/orders'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end

    # Prueba 9: Retorna array vacío si customer no tiene órdenes
    it 'retorna array vacío si customer no tiene órdenes' do
      create(:order, customer_id: 1)

      get '/orders?customer_id=999'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to eq([])
    end

    # Prueba 10: Serializa correctamente campos necesarios
    it 'serializa correctamente en JSON' do
      order = create(:order,
        customer_id: 1,
        product_name: 'Café Prueba',
        quantity: 1,
        price: 8000,
        status: 'pending'
      )

      get '/orders'

      json = JSON.parse(response.body)
      expect(json[0]).to have_key('id')
      expect(json[0]).to have_key('customer_id')
      expect(json[0]).to have_key('product_name')
      expect(json[0]).to have_key('quantity')
      expect(json[0]).to have_key('price')
      expect(json[0]).to have_key('status')
      expect(json[0]).to have_key('created_at')
    end
  end
end
