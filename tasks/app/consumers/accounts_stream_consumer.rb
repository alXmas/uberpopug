class AccountsStreamConsumer < ApplicationConsumer
  def consume
    params_batch.payloads.each do |payload|
      Karafka.logger.info "SYKAAAA"
      puts '-' * 80
      p payload
      puts '-' * 80

      data = payload['data']

      case payload['event_name']
      when 'AccountCreated'
        Account.create!(
          public_id: data['public_id'],
          email: data['email'],
          role: data['role'],
          full_name: data['full_name']
        )
      when 'AccountUpdated'
        Account.transaction do
          account = Account.find_by(public_id: data['public_id'])
          account.update!(
            email: data['email'],
            full_name: data['full_name']
          )
        end
      when 'AccountDeleted'
        Account.transaction do
          account = Account.find_by(public_id: data['public_id'])
          account.destroy!
        end
      else
        # store in db
      end
    end
  end
end
