# frozen_string_literal: true

class OrdersController < ApplicationController
  CUSTOMER_SERVICE_URL = "http://localhost:3001".freeze

  # GET /orders?customer_id=1
  # Lista pedidos filtrados por customer_id (query param).
  def index
    orders = if params[:customer_id].present?
               Order.where(customer_id: params[:customer_id])
             else
               Order.all
             end

    render json: orders, status: :ok
  end

  # POST /orders
  # Crea pedido tras validar que el customer_id existe (llamada HTTP a customer-service).
  # Preparado para emitir evento RabbitMQ después de guardar (siguiente paso).
  def create
    customer_id = order_params[:customer_id]
    return render json: { error: "customer_id es obligatorio" }, status: :unprocessable_entity if customer_id.blank?

    # Validar que el cliente existe vía HTTP a customer-service (Faraday)
    unless customer_exists?(customer_id)
      return render json: { error: "Cliente #{customer_id} no encontrado en customer-service" },
                    status: :not_found
    end

    @order = Order.new(order_params)

    if @order.save
      # Publica evento para que customer-service actualice orders_count (consistencia eventual)
      OrderEventPublisher.publish_order_created(@order)
      render json: @order, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
  end

  # Llamada HTTP con Faraday a customer-service para validar que el cliente existe.
  # URL: http://localhost:3001 (puerto 3001 = customer-service, 3000 = order-service).
  def customer_exists?(customer_id)
    conn = Faraday.new(url: CUSTOMER_SERVICE_URL)

    response = conn.get("/customers/#{customer_id}")
    response.status == 200
  rescue Faraday::Error => e
    Rails.logger.error("Faraday error al validar cliente #{customer_id}: #{e.message}")
    false
  end
end
