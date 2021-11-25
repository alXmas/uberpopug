# frozen_string_literal: true

class DeviseCreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :email, index: true, unique: true
      t.string :password_digest
      t.string :full_name
      t.string :state
      t.string :role
      t.string :position
      t.uuid :public_id, default: 'gen_random_uuid()', null: false

      t.timestamps
    end
  end
end
