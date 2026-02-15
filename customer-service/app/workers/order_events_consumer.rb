# frozen_string_literal: true

# Consumer Bunny que escucha la cola order_events.
# Al recibir order.created: incrementa Customer.orders_count.
# Corre en background: bin/rails order_events:consume (o rails runner)
# Consistencia eventual: orders_count se actualiza unos segundos después del POST.
class OrderEventsConsumer
  ROUTING_KEY_CREATED = "order.created".freeze

  def run
    cfg = Rails.application.config.rabbitmq

    puts "[OrderEventsConsumer] Conectando a Bunny (#{cfg[:host]}:#{cfg[:port]})..."
    conn = Bunny.new(
      host: cfg[:host],
      port: cfg[:port],
      user: cfg[:user],
      password: cfg[:password]
    )
    conn.start
    puts "[OrderEventsConsumer] Conectado a RabbitMQ."

    channel = conn.create_channel
    channel.prefetch(1)

    exchange = channel.direct(cfg[:exchange], durable: true)
    queue = channel.queue(cfg[:queue], durable: true)
    queue.bind(exchange, routing_key: cfg[:routing_key_created])

    puts "[OrderEventsConsumer] Suscrito a cola '#{cfg[:queue]}' (routing_key=#{ROUTING_KEY_CREATED})"
    Rails.logger.info("[OrderEventsConsumer] Escuchando cola #{cfg[:queue]}...")

    queue.subscribe(block: true, manual_ack: true) do |delivery_info, _metadata, payload|
      puts "[OrderEventsConsumer] << Mensaje recibido | routing_key=#{delivery_info.routing_key} | payload=#{payload[0..200]}"
      handle_message(payload, channel, delivery_info)
    end
  rescue Interrupt => _e
    puts "[OrderEventsConsumer] Detenido (Ctrl+C)."
    Rails.logger.info("[OrderEventsConsumer] Detenido.")
  rescue Bunny::Exception, StandardError => e
    puts "[OrderEventsConsumer] Error: #{e.class} - #{e.message}"
    puts e.backtrace.first(5).join("\n")
    Rails.logger.error("[OrderEventsConsumer] Error: #{e.message}")
  ensure
    channel&.close
    conn&.close
  end

  private

  def handle_message(payload, channel, delivery_info)
    puts "[OrderEventsConsumer] Parseando JSON..."
    data = JSON.parse(payload)
    routing_key = delivery_info.routing_key
    puts "[OrderEventsConsumer] routing_key=#{routing_key.inspect} (esperado '#{ROUTING_KEY_CREATED}')"

    if routing_key == ROUTING_KEY_CREATED
      process_order_created(data, channel, delivery_info)
    else
      puts "[OrderEventsConsumer] routing_key no coincide, nack (requeue)"
      channel.nack(delivery_info.delivery_tag, false, true)
    end
  rescue JSON::ParserError => e
    puts "[OrderEventsConsumer] JSON inválido: #{e.message}"
    Rails.logger.error("[OrderEventsConsumer] JSON inválido: #{e.message}")
    channel.nack(delivery_info.delivery_tag, false, false)
  rescue StandardError => e
    puts "[OrderEventsConsumer] Error en handle_message: #{e.message}"
    puts e.backtrace.first(3).join("\n")
    Rails.logger.error("[OrderEventsConsumer] Error: #{e.message}")
    channel.nack(delivery_info.delivery_tag, false, true)
  end

  def process_order_created(data, channel, delivery_info)
    customer_id = data["customer_id"]
    puts "[OrderEventsConsumer] Buscando Customer id=#{customer_id}..."

    customer = Customer.find_by(id: customer_id)

    if customer
      puts "[OrderEventsConsumer] Customer encontrado: #{customer.name}, orders_count ANTES=#{customer.orders_count}"
      customer.increment!(:orders_count)
      puts "[OrderEventsConsumer] Customer #{customer_id} orders_count DESPUÉS=#{customer.reload.orders_count} | ack"
      Rails.logger.info("[OrderEventsConsumer] Customer #{customer_id} orders_count=#{customer.orders_count}")
      channel.ack(delivery_info.delivery_tag)
    else
      puts "[OrderEventsConsumer] Customer #{customer_id} no encontrado, descartando (ack sin incrementar)"
      Rails.logger.warn("[OrderEventsConsumer] Customer #{customer_id} no encontrado")
      channel.ack(delivery_info.delivery_tag)
    end
  end
end
