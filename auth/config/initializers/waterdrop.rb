WaterDrop.setup do |config|
  config.deliver = true
  config.kafka.seed_brokers = ['kafka://localhost:29092']
  config.logger = Rails.logger
end
