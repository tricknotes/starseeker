require "#{Rails.root}/config/environment"

desc 'Send ranking mail to all users'
task :send_ranking do
  User.email_sendables.each do |user|
    MyHotRepository.notify(user).deliver
    puts "Send ranking mail to \033[36m%s(%s)\033[39m." % [user.username, user.email]
  end
end
