# frozen_string_literal: true

Wisper.subscribe(AuthListener, 
  on: [
    :account_updated,
    :account_role_changed,
    :access_deleted,
    :account_created
  ],
  broadcaster: :kafka
)
