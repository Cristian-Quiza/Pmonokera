# frozen_string_literal: true

class OrdersController < ApplicationController
  CUSTOMER_SERVICE_URL = ENV.fetch('CUSTOMER_SERVICE_URL', 'http://localhost:3001').freeze
  # TODO: Implementar circuit breaker para customer-service fallback
  # TODO: Agregar caching de validación de clientes (30s TTL)

  # GET /orders?customer_id=1
  def index
    orders = if params[:customer_id].present?
               Order.where(customer_id: params[:customer_id])
             else
               Order.all
             end

    render json: orders.as_json(only: [:id, :customer_id, :product_name, :quantity, :price, :status, :created_at]), status: :ok
  rescue StandardError => e
    Rails.logger.error("Error listing orders: #{e.message}")
    render json: { error: "Error al listar órdenes" }, status: :internal_server_error
  end

  # POST /orders
  def create
    customer_id = order_params[:customer_id]
    return render json: { error: "customer_id es requerido" }, status: :unprocessable_entity if customer_id.blank?

    unless customer_exists?(customer_id)
      return render json: { error: "Cliente #{customer_id} no encontrado" }, status: :not_found
    end

    @order = Order.new(order_params)

    if @order.save
      OrderEventPublisher.publish_order_created(@order)
      render json: @order, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("Error creating order: #{e.message}")
    render json: { error: "Error al crear la orden" }, status: :internal_server_error
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, :product_name, :quantity, :price, :status)
  end

  def customer_exists?(customer_id)
    # TODO: Implementar retry logic con exponential backoff
    conn = Faraday.new(url: CUSTOMER_SERVICE_URL, request: { timeout: 5 })
    response = conn.get("/customers/#{customer_id}")
    response.status == 200
  rescue Faraday::ConnectionFailed => e
    Rails.logger.warn("Connection error to customer-service: #{e.message}")
    false
  rescue Faraday::TimeoutError => e
    Rails.logger.warn("Timeout calling customer-service: #{e.message}")
    false
  rescue => e
    Rails.logger.error("Unexpected error validating customer: #{e.message}")
    false
  end
end
