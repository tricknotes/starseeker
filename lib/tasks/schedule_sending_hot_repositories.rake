desc 'Schedule sending hot repositories mail'
task :schedule_sending_hot_repositories => :environment do
  users = User.email_sendables

  DailyMailScheduler.schedule(users)
end
