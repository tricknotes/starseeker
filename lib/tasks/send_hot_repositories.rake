desc 'Send hot repositories mail to all users'
task :send_hot_repositories => :environment do
  DailyMailScheduler.send_mail_to_scheduled_users
end
