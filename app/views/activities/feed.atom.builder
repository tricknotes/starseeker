atom_feed do |feed|
  feed.title 'starseeker | My hot repositories (@%s)' % @user.username
  feed.updated @latest_event.created_at if @latest_event

  @star_events.starred_ranking.each do |repo_name, events, repo|
    feed.entry(
      repo,
      published: repo.created_at,
      updated: events.first.created_at,
      url: github_url(repo.full_name)
    ) do |entry|
      entry.title repo_name
      entry.content(<<~HTML, type: :html)
        <blockquote>#{h repo.description}</blockquote>
        starred by #{
          safe_join(
            events.map {|event|
              "#{image_tag(event['actor']['avatar_url'], size: '20x20')}#{event['actor']['login']}"
            },
          ',')
        }
      HTML
    end
  end
end
