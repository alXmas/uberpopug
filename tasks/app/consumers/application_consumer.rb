# frozen_string_literal: true

class ApplicationConsumer < Racecar::Consumer
  Measured = Struct.new(:message, :statsd) do
    MESSAGE_BYTES = 'kafka_consumer_message_bytes'
    REQUEST_LATENCY = 'kafka_consumer_request_latency_seconds'
    REQUESTS_TOTAL = 'kafka_consumer_requests_total'
    ERRORS_COUNTER = 'kafka_consumer_errors_count'
    STATUS_SUCCESS = { kafka_status: 'success' }.freeze
    STATUS_FAILURE = { kafka_status: 'failure' }.freeze

    def call(&block)
      tags = { kafka_topic: message.topic }
      bytes = (message.value || '').bytes.size

      statsd.count(MESSAGE_BYTES, bytes, format_tags(tags))
      statsd.time(REQUEST_LATENCY, format_tags(tags), &block)
      statsd.increment(REQUESTS_TOTAL, format_tags(tags.merge(STATUS_SUCCESS)))
    rescue StandardError => exception
      statsd.increment(REQUESTS_TOTAL, format_tags(tags.merge(STATUS_FAILURE)))
      statsd.increment(ERRORS_COUNTER, format_tags(tags.merge(error: exception.class.to_s)))
      raise exception
    end

    private

    def format_tags(tags)
      tags = tags.map { |name, value| "#{name}:#{value}" }
      { tags: tags }
    end
  end

  class Logged
    attr_reader :message, :reraise_exception

    def initialize(message, reraise_exception)
      @message = message
      @reraise_exception = reraise_exception
    end

    def call(&block)
      ErrorTracker.reset_context
      ErrorTracker.with_context(error_context, &block)
      log_processed
    rescue StandardError => exception
      handle_exception(exception)
    end

    private

    def log_processed
      logger.info("processed #{id}")
    end

    def handle_exception(exception)
      log_failed(exception)

      raise(exception) if reraise_exception

      ErrorTracker.notify(exception)
    end

    def log_failed(exception)
      logger.error("failed #{id} #{exception.class} - #{exception.message}")
    end

    def bytes
      @bytes ||= (message.value || '').bytes.size
    end

    def id
      "#{message.topic}-#{message.partition}:#{message.offset} (#{bytes} bytes)"
    end

    def error_context
      {
        kafka: {
          key: message.key,
          topic: message.topic,
          partition: message.partition,
          offset: message.offset,
          message: { bytes: bytes }
        }
      }
    end

    def logger
      Racecar.logger
    end
  end

  def process(message)
    Chewy.strategy(:atomic) do
      Logged.new(message, true).call do
        Measured.new(message, STATSD).call { process_message(message) }
      end
    end
  end

  private

  def decode(value)
    Oj.load(value, symbol_keys: true)
  end
end
