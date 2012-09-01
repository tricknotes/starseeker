require "#{Rails.root}/config/environment"

desc 'Fetch referenced repositories'
task :fetch_repositories do
  followings = User.all.flat_map do |user|
    puts "Search following about '%s'..." % user.username
    puts "Hit %d followings about %s." % [user.followings.count,  user.username]
    user.followings
  end
  logins = followings.map(&:login).uniq
  puts "%d users found." % logins.count

  watch_events = WatchEvent.all_by(logins).latest(1.day.ago)
  repo_names = watch_events.map {|watch_event| watch_event.repo['name'] }.uniq
  puts "%d repositories found." % repo_names.count
  repo_names.each do |repo_name|
    puts "Fetching repository '%s'." % repo_name
    repo = Repository.fetch!(repo_name)
    puts "Ignore repository '%s' because of not found." if repo.nil?
  end
end
