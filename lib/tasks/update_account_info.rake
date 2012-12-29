require "#{Rails.root}/config/environment"

desc 'Update account info with github.com'
task :update_account_info do
  User.all.each do |user|
    puts "Fetch user info about \033[36m%s\033[39m..." % user.username
    begin
      user_info = user.github_client.user
    rescue => e
      # TODO Notify error to admin
      $stderr.puts ["#{e.class} #{e.message}:", *e.backtrace.map {|m| '  '+m }].join("\n")
      next
    end

    {
      username: user_info['login'],
      name: user_info['name'],
      avatar_url: user_info['avatar_url']
    }.each {|attribute, value| user.send("#{attribute}=", value) }

    if user.changed?
      change_detail = user.changes.map {|attribute, (before, after)| '%s: %s -> %s' % [attribute, before, after] }.join(', ')
      puts "User \033[36m%s\033[39m changed (%s)." % [user.username, change_detail]
    else
      puts "User \033[36m%s\033[39m not changed." % [user.username]
    end

    user.save!
  end
end
