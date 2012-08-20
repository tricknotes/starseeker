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
  reponames = watch_events.map {|watch_event| watch_event.repo['name'] }.uniq
  puts "%d repositories found." % reponames.count
  reponames.each do |reponame|
    puts "Fetching repository '%s'." % reponame
    repo = Repository.fetch!(reponame)
    puts "Ignore repository '%s' because of not found." if repo.nil?
  end
end
