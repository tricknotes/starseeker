require "#{Rails.root}/config/environment"

desc 'Fetch referenced repositories'
task :fetch_repositories do
  Repository.delete_all

  followings = []
  User.all.each do |user|
    puts "Search following about \033[36m%s\033[39m...\n" % user.username
    puts "Hit \033[33m%d\033[39m followings about \033[36m%s\033[39m.\n" % [user.followings.count,  user.username]
    followings += user.followings
  end

  logins = followings.map(&:login).uniq
  puts "\033[33m%d\033[39m users found." % logins.count

  star_events = StarEvent.all_by(logins).latest(1.day.ago)
  repo_names = star_events.map {|star_event| star_event.repo['name'] }.uniq
  puts "\033[33m%d\033[39m repositories found." % repo_names.count

  repo_names.map do |repo_name|
    repo = Repository.fetch!(repo_name)
    message = if repo
        "Fetched repository \033[36m%s\033[39m.\n"
      else
        "Ignore repository \033[31m%s\033[39m because of not found.\n"
      end
    puts message % repo_name
  end
end
