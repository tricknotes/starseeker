namespace :star_events do
  desc 'Fetch star events for all users and their followings from GitHub'
  task fetch: :environment do
    since = 2.hours.ago

    logins = User.find_each.flat_map { |user|
      followings =
        begin
          user.followings.map { |following| following['login'] }
        rescue => e
          Rails.logger.error "Failed to fetch followings for @#{user.username}: #{e.message}"

          []
        end

       followings + [user.username]
    }.uniq

    Rails.logger.info "Fetching star events for #{logins.size} logins"

    StarEvent.fetch_and_upsert(client: Settings.github_client, logins: logins, since: since, debug: true)
  end
end
