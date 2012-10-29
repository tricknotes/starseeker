require "#{Rails.root}/config/environment"

desc 'Send hot repositories mail to all users'
task :send_hot_repositories do
  User.email_sendables.each do |user|
    MyHotRepository.notify(user).deliver
    puts "Send hot repositories mail to \033[36m%s(%s)\033[39m." % [user.username, user.email]
  end
end
