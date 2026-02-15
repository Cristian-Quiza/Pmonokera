# frozen_string_literal: true

namespace :order_events do
  desc "Consume eventos de pedidos (order.created) y actualiza orders_count en Customer"
  task consume: :environment do
    OrderEventsConsumer.new.run
  end
end
