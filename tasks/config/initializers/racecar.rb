# frozen_string_literal: true

Racecar.config.on_error do |exception, info = {}|
  ErrorTracker.notify(exception,
    context:
      {
        message: exception.message,
        topic: info[:topic],
        partition: info[:partition],
        offset: info[:offset]
      }
  )
end
