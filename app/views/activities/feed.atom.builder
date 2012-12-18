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
      entry.content(<<-HTML, type: :html)
        #{
          link_to(
            image_tag(repo['owner']['avatar_url'], size: '30x30'),
            github_url(repo['owner']['login'])
          )
        }
        #{h repo.description}
        #{content_tag('ul') do
          events.map do |event|
            content_tag('li') do
              link_to(
                image_tag(event['actor']['avatar_url'], size: '20x20'),
                github_url(event['actor']['login'])
              )
            end
          end.join.html_safe
        end}
      HTML
    end
  end
end
