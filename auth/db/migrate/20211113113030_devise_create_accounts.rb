# frozen_string_literal: true

class DeviseCreateAccounts < ActiveRecord::Migration[6.1]
  def change
    enable_extension 'pgcrypto'
    
    create_table :accounts do |t|
      t.string :email, index: true, unique: true
      t.string :encrypted_password, null: false, default: ""

      t.uuid :public_id, default: 'gen_random_uuid()', null: false
      ## Account information
      t.string   :full_name
      t.string   :position

      ## Account information
      t.boolean   :active, default: true

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at
      

      t.timestamps
    end
  end
end
