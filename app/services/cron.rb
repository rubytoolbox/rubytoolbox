# frozen_string_literal: true

#
# This basic utility class is used for running recurring tasks
# based on the current time. It is meant to be invoked once per
# hour, i.e. using the Heroku hourly scheduler and `rake cron`
#
class Cron
  def run(time: Time.current.utc)
    RubygemsUpdateSchedulerJob.perform_async

    case time.hour
    when 0
      RubygemsSyncJob.perform_async
    end
  rescue StandardError => err
    Appsignal.set_error err
    raise err
  end
end
