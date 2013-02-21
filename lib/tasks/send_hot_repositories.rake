require "#{Rails.root}/config/environment"

desc 'Send hot repositories mail to all users'
task :send_hot_repositories do
  User.email_sendables.each do |user|
    label = '%s(%s)' % [user.username, user.email]

    begin
      if user.star_events_by_followings_with_me.latest(1.day.ago).present?
        MyHotRepository.notify(user).deliver

        message = "Send hot repositories mail to \033[36m%s\033[39m." % [label]
      else
        message = "Skip sending mail to \033[33m%s\033[39m. Because star events to him are empty." % [label]
      end
    rescue Octokit::Unauthorized
      message = "Skip sending mail to \033[31m%s\033[39m. Because of unauthorized Token." % [label]
    end

    puts message
  end
end
