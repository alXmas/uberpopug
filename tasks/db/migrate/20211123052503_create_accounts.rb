class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :email
      t.string :full_name
      t.string :role
      t.string :public_id

      t.timestamps
    end
  end
end
