# frozen_string_literal: true

class EventsConsumer < ApplicationConsumer
  self.group_id = 'uberpopug-wisper-consumer'
  subscribes_to 'wisper_events', start_from_beginning: false

  def process_message(message)
    parsed_message = decode(message.value)

    subscriber = parsed_message.fetch(:subscriber)
    event = parsed_message.fetch(:event)
    args = parsed_message.fetch(:args)

    Object.const_get(subscriber).public_send(event, *args)
  end
end
