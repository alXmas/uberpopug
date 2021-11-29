class EventProducer
  class << self
    def call(event:, topic:)
      WaterDrop::SyncProducer.call(event.to_json, topic: topic)
    end
  end
end
