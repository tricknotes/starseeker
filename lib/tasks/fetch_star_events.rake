namespace :star_events do
  desc 'Fetch star events for all users and their followings from GitHub'
  task fetch: :environment do
    since = 2.hours.ago

    User.find_each do |user|
      following_names = user.followings.map { |following| following['login'] }
      logins = (following_names + [user.username]).uniq

      Rails.logger.info "Fetching star events for #{user.username} (and #{following_names.size} followings)"
      StarEvent.fetch_and_upsert(client: user.github_client, logins: logins, since: since)
    rescue => e
      Rails.logger.error "Failed to fetch star events for #{user.username}: #{e.message}"
    end
  end
end
