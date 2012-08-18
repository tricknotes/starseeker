require "#{Rails.root}/config/environment"

desc 'Fetch referenced repositories'
task :fetch_repositories do
  followings = User.all.flat_map do |user|
    puts "Search following about '%s'..." % user.username
    puts "Hit %d followings about %s." % [user.followings.count,  user.username]
    user.followings
  end
  logins = followings.map(&:login).uniq

  watch_events = WatchEvent.all_by(logins).latest(1.day.ago)
  watch_events.each do |watch_event|
    reponame = watch_event.repo['name']
    puts "Fetching repository '%s'." % reponame
    Repository.fetch!(reponame)
  end
end
