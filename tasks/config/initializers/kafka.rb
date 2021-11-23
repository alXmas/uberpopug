# frozen_string_literal: true

raise 'Statsd is not initialized' unless defined?(STATSD)

require 'kafka/datadog'
Kafka::Datadog.statsd = STATSD
