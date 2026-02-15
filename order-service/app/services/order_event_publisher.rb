# frozen_string_literal: true

# Servicio para publicar eventos de pedidos a RabbitMQ (Bunny).
# Gem estándar Bunny: cliente oficial/nativo para RabbitMQ en Ruby.
# Cola directa: exchange tipo direct enruta por routing key exacta.
# Routing key permite filtrar mensajes (ej: order.created, order.cancelled).
class OrderEventPublisher
  def self.publish_order_created(order)
    new.publish_order_created(order)
  end

  def publish_order_created(order)
    cfg = Rails.application.config.rabbitmq

    conn = Bunny.new(
      host: cfg[:host],
      port: cfg[:port],
      user: cfg[:user],
      password: cfg[:password]
    )
    conn.start

    channel = conn.create_channel
    exchange = channel.direct(cfg[:exchange], durable: true)
    queue = channel.queue(cfg[:queue], durable: true)
    queue.bind(exchange, routing_key: cfg[:routing_key_created])

    payload = {
      order_id: order.id,
      customer_id: order.customer_id,
      event: cfg[:routing_key_created]
    }.to_json

    exchange.publish(payload, routing_key: cfg[:routing_key_created], persistent: true)
    Rails.logger.info("[OrderEventPublisher] Evento publicado: #{payload}")

    channel.close
    conn.close
  rescue Bunny::Exception, StandardError => e
    Rails.logger.error("[OrderEventPublisher] Error al publicar: #{e.message}")
    # No relanzamos: el pedido ya se guardó; el consumer puede recuperar eventualmente
  end
end
