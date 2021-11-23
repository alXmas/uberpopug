# frozen_string_literal: true

WisperKafka::Settings.topic = 'wisper_events'

Wisper.subscribe(AccountListener, 
  on: [
    :account_updated,
    :account_role_changed,
    :access_deleted,
    :account_created
  ],
  broadcaster: :kafka
)
