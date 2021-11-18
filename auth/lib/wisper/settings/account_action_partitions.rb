# frozen_string_literal: true

module Wisper::Settings::AccountActionPartitions
  def kafka_options(public_id:, **_args)
    { topic: 'wisper_events', partition_key: "public-#{public_id}" }
  end
end
