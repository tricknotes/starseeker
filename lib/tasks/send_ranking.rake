require "#{Rails.root}/config/environment"

desc 'Send ranking mail to all users'
task :send_ranking do
  User.email_sendables.each do |user|
    MyHotRepository.notify(user).deliver
  end
end
