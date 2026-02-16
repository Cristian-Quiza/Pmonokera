# frozen_string_literal: true

class CustomersController < ApplicationController
  # TODO: Implementar caching en Redis para GET /customers/:id

  # GET /customers/:id
  def show
    @customer = Customer.find_by(id: params[:id])

    if @customer
      render json: {
        customer_name: @customer.name,
        address: @customer.address,
        orders_count: @customer.orders_count
      }, status: :ok
    else
      render json: { error: "Cliente no encontrado" }, status: :not_found
    end
  rescue StandardError => e
    Rails.logger.error("Error fetching customer #{params[:id]}: #{e.message}")
    render json: { error: "Error interno del servidor" }, status: :internal_server_error
  end
end
