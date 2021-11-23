class CreateAccounts < ActiveRecord::Migration[6.1]
  enable_extension 'pgcrypto'

  def change
    create_table :accounts do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""

      t.uuid :public_id, default: "gen_random_uuid()", null: false

      ## Account information
      t.string   :full_name
      t.string   :position
      t.string   :role

      t.timestamps null: false
      t.datetime :disabled_at
    end
  end
end
