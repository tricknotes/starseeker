namespace :star_events do
  desc 'Fetch star events using each app-user\'s own GitHub token (multiplies rate limit). hours=N or FETCH_HOURS=N to set lookback period (default: 2)'
  task :fetch, [:hours] => :environment do |_, args|
    hours = (args[:hours] || ENV['FETCH_HOURS'] || 2).to_i
    since = hours.hours.ago

    Rails.logger.info "[star_events:fetch] start: hours=#{hours}, since=#{since}"
    Rails.logger.info "[star_events:fetch] #{User.count} users found"

    # Process users in slices of FETCH_CONCURRENCY.  Waiting for each slice to
    # complete before starting the next one lets GC.compact reclaim memory from
    # finished users (logins arrays, Sawyer objects, etc.) before new users
    # are loaded.  This avoids accumulating all users' data in memory at once.
    pool = Concurrent::FixedThreadPool.new(StarEvent::FETCH_CONCURRENCY)

    User.find_in_batches(batch_size: StarEvent::FETCH_CONCURRENCY) do |user_batch|
      futures = user_batch.map do |user|
        Concurrent::Future.execute(executor: pool) do
          client = user.github_client
          logins = (user.followings + [user.username]).uniq
          Rails.logger.info "[star_events:fetch] @#{user.username}: #{logins.size} logins"

          StarEvent.fetch_and_upsert(
            token:           client.access_token,
            logins:          logins,
            since:           since,
            debug:           true,
            fallback_client: client
          )
        end
      end

      futures.each do |future|
        future.value
        if future.rejected?
          Rails.logger.error "[star_events:fetch] failed: #{future.reason.class}: #{future.reason.message}"
        end
      end

      GC.compact
    end

    pool.shutdown
    pool.wait_for_termination(60)

    Rails.logger.info "[star_events:fetch] finished"
  end
end
