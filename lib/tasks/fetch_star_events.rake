namespace :star_events do
  desc 'Fetch star events for all users and their followings from GitHub'
  task fetch: :environment do
    since = 2.hours.ago
    pool = Concurrent::FixedThreadPool.new(StarEvent::FETCH_CONCURRENCY)

    logins = User.all.map { |user|
      Concurrent::Future.execute(executor: pool) {
        begin
          user.followings.map { |following| following['login'] } + [user.username]
        rescue => e
          Rails.logger.error "Failed to fetch followings for @#{user.username}: #{e.message}"
          [user.username]
        end
      }
    }.flat_map(&:value).uniq

    pool.shutdown
    pool.wait_for_termination(30)

    Rails.logger.info "Fetching star events for #{logins.size} logins"

    StarEvent.fetch_and_upsert(client: Settings.github_client, logins: logins, since: since, debug: true)
  end
end
