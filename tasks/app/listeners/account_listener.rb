# frozen_string_literal: true

class AccountListener
  def kafka_options(public_id:, **_args)
    { topic: 'wisper_events', partition_key: "public-#{public_id}" }
  end

  def self.account_created(public_id:, **)
    p public_id
  end

  def self.account_updated(public_id:, **)
    p public_id
  end

  def self.account_role_changed(public_id:, **)
    p public_id
  end

  def self.access_deleted(public_id:, **)
    p public_id
  end
end
