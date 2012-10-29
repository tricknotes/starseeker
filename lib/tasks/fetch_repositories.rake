require "#{Rails.root}/config/environment"

desc 'Fetch referenced repositories'
task :fetch_repositories do
  MAX_CONNECTION_COUNT = 3

  Repository.delete_all

  followings = []
  mutex = Mutex.new
  User.all.each_slice(MAX_CONNECTION_COUNT).each do |users|
    users.map do |user|
      Thread.new do
        puts "Search following about \033[36m%s\033[39m...\n" % user.username
        puts "Hit \033[33m%d\033[39m followings about \033[36m%s\033[39m.\n" % [user.followings.count,  user.username]
        mutex.synchronize { followings += user.followings }
      end
    end.each(&:join)
  end

  logins = followings.map(&:login).uniq
  puts "\033[33m%d\033[39m users found." % logins.count

  watch_events = WatchEvent.all_by(logins).latest(1.day.ago)
  repo_names = watch_events.map {|watch_event| watch_event.repo['name'] }.uniq
  puts "\033[33m%d\033[39m repositories found." % repo_names.count

  repo_names.each_slice(MAX_CONNECTION_COUNT).each do |repo_name_block|
    repo_name_block.map do |repo_name|
      Thread.new do
        repo = Repository.fetch!(repo_name)
        message = if repo
            "Fetched repository \033[36m%s\033[39m.\n"
          else
            "Ignore repository \033[31m%s\033[39m because of not found.\n"
          end
        puts message % repo_name
      end
    end.each(&:join)
  end
end
