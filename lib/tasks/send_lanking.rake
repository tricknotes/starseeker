require "#{Rails.root}/config/environment"

desc 'Send lanking mail to all users'
task :send_lanking do
  User.where(receive_mail: true).each do |user|
    MyHotRepository.notify(user).deliver
  end
end
