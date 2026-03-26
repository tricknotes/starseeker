namespace :star_events do
  desc 'Fetch star events for all users and their followings from GitHub. hours=N or FETCH_HOURS=N to set lookback period (default: 2)'
  task :fetch, [:hours] => :environment do |_, args|
    hours = (args[:hours] || ENV['FETCH_HOURS'] || 2).to_i
    since = hours.hours.ago

    Rails.logger.info "[star_events:fetch] start: hours=#{hours}, since=#{since}"

    Rails.logger.info "[star_events:fetch] #{User.count} users found"

    logins = []
    User.find_each do |user|
      Rails.logger.info "[star_events:fetch] fetching followings for @#{user.username}"
      followings = user.followings
      GC.start
      Rails.logger.info "[star_events:fetch] @#{user.username}: #{followings.size} followings"
      logins.concat(followings + [user.username])
    rescue => e
      Rails.logger.error "[star_events:fetch] failed to fetch followings for @#{user.username}: #{e.class}: #{e.message}"
      logins << user.username
    end
    logins.uniq!

    Rails.logger.info "[star_events:fetch] #{logins.size} unique logins to fetch"

    logins.each_slice(10) do |logins|
      Rails.logger.info "[star_events:fetch] fetching star events for @#{logins}"
      StarEvent.fetch_and_upsert(client: Settings.github_client, logins: logins, since: since, debug: true)
      GC.start
    end

    Rails.logger.info "[star_events:fetch] finished"
  end
end
