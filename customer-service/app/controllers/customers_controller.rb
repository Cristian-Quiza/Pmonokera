# frozen_string_literal: true

class CustomersController < ApplicationController
  # GET /customers/:id
  # Devuelve name, address, orders_count del cliente (requisito: consultar info del cliente).
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
  end
end
