desc 'Notify status to Idobata'
task :notify_status_to_idobata => :environment do
  raise 'Missing `Settings.idobata_hook_url`.' unless hook_url = Settings.idobata_hook_url

  require 'net/http'

  mail_not_sent_count = DailyMailScheduler.scheduled_users.count

  message = if mail_not_sent_count.zero?
    'All users can receive daily mail :smile:'
  else
    ":scream: :scream: :scream: #{mail_not_sent_count} users couldn't receive daily mail. :scream: :scream: :scream:"
  end

  Net::HTTP.post_form URI(hook_url), source: message
end
