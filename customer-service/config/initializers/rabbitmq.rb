# frozen_string_literal: true

# Configuración Bunny (cliente RabbitMQ) para customer-service (consumer).
# Debe coincidir con order-service para conectar a la misma cola.
# Management UI: http://localhost:15672

Rails.application.config.rabbitmq = {
  host: ENV.fetch("RABBITMQ_HOST", "localhost"),
  port: ENV.fetch("RABBITMQ_PORT", 5672).to_i,
  user: ENV.fetch("RABBITMQ_USER", "guest"),
  password: ENV.fetch("RABBITMQ_PASSWORD", "guest"),
  queue: "order_events",
  exchange: "order_exchange",
  routing_key_created: "order.created"
}
