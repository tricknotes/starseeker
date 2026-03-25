namespace :star_events do
  desc 'Fetch star events for all users and their followings from GitHub. hours=N or FETCH_HOURS=N to set lookback period (default: 2)'
  task :fetch, [:hours] => :environment do |_, args|
    hours = (args[:hours] || ENV['FETCH_HOURS'] || 2).to_i
    since = hours.hours.ago

    Rails.logger.info "[star_events:fetch] start: hours=#{hours}, since=#{since}"

    users = User.all.to_a
    Rails.logger.info "[star_events:fetch] #{users.size} users found"

    logins = users.flat_map do |user|
      Rails.logger.info "[star_events:fetch] fetching followings for @#{user.username}"
      followings = user.followings.map { |following| following['login'] }
      Rails.logger.info "[star_events:fetch] @#{user.username}: #{followings.size} followings -> #{(followings + [user.username]).uniq.size} logins"
      followings + [user.username]
    rescue => e
      Rails.logger.error "[star_events:fetch] failed to fetch followings for @#{user.username}: #{e.class}: #{e.message}"
      [user.username]
    end.uniq

    Rails.logger.info "[star_events:fetch] #{logins.size} unique logins to fetch"

    StarEvent.fetch_and_upsert(client: Settings.github_client, logins: logins, since: since, debug: true)

    Rails.logger.info "[star_events:fetch] finished"
  end
end
