namespace :star_events do
  desc 'Fetch star events for all users and their followings from GitHub. hours=N or FETCH_HOURS=N to set lookback period (default: 2)'
  task :fetch, [:hours] => :environment do |_, args|
    hours = (args[:hours] || ENV['FETCH_HOURS'] || 2).to_i
    since = hours.hours.ago

    Rails.logger.info "[star_events:fetch] start: hours=#{hours}, since=#{since}"
    Rails.logger.info "[star_events:fetch] #{User.count} users found"

    pool = Concurrent::FixedThreadPool.new(StarEvent::FETCH_CONCURRENCY)
    mutex = Mutex.new
    logins = []
    futures = []

    User.find_each do |user|
      futures << Concurrent::Future.execute(executor: pool) {
        Rails.logger.info "[star_events:fetch] fetching followings for @#{user.username}"
        followings = user.followings
        Rails.logger.info "[star_events:fetch] @#{user.username}: #{followings.size} followings"
        mutex.synchronize { logins.concat(followings + [user.username]) }
      }
    end

    futures.each do |future|
      future.value
      if future.rejected?
        Rails.logger.error "[star_events:fetch] failed to fetch followings: #{future.reason.class}: #{future.reason.message}"
      end
    end

    pool.shutdown
    pool.wait_for_termination(60)
    logins.uniq!
    GC.compact

    Rails.logger.info "[star_events:fetch] #{logins.size} unique logins to fetch"

    StarEvent.fetch_and_upsert(client: Settings.github_client, logins: logins, since: since, debug: true)

    Rails.logger.info "[star_events:fetch] finished"
  end
end
