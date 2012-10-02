require "#{Rails.root}/config/environment"

desc 'Fetch referenced repositories'
task :fetch_repositories do
  followings = User.all.flat_map do |user|
    puts "Search following about \033[36m%s\033[39m..." % user.username
    puts "Hit \033[33m%d\033[39m followings about \033[36m%s\033[39m." % [user.followings.count,  user.username]
    user.followings
  end
  logins = followings.map(&:login).uniq
  puts "\033[33m%d\033[39m users found." % logins.count

  watch_events = WatchEvent.all_by(logins).latest(1.day.ago)
  repo_names = watch_events.map {|watch_event| watch_event.repo['name'] }.uniq
  puts "\033[33m%d\033[39m repositories found." % repo_names.count
  repo_names.each do |repo_name|
    puts "Fetching repository \033[36m%s\033[39m." % repo_name
    repo = Repository.fetch!(repo_name)
    puts "Ignore repository \033[31m%s\033[39m because of not found." if repo.nil?
  end
end
