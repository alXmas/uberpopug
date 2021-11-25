class Account < ApplicationRecord
  include Wisper::Publisher
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  
  has_many :access_grants,
         class_name: 'Doorkeeper::AccessGrant',
         foreign_key: :resource_owner_id,
         dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
         class_name: 'Doorkeeper::AccessToken',
         foreign_key: :resource_owner_id,
         dependent: :delete_all # or :destroy if you need callbacks

  enum role: {
    admin: 'admin',
    worker: 'worker',
    manager: 'manager',
  }

  after_create do
    account = self

    # ----------------------------- produce event -----------------------
    event = {
      public_id: account.public_id,
      email: account.email,
      full_name: account.full_name,
      position: account.position
    }

    broadcast(:account_created, **event)
  end
end
