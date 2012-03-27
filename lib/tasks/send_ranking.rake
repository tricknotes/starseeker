require "#{Rails.root}/config/environment"

desc 'Send ranking mail to all users'
task :send_ranking do
  User.where(receive_mail: true, activation_state: 'active').each do |user|
    MyHotRepository.notify(user).deliver
  end
end
