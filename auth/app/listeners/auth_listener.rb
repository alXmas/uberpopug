# frozen_string_literal: true

class AuthListener
  extend Wisper::Settings::AuthListener

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
