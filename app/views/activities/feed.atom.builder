atom_feed do |feed|
  feed.title 'starseeker | My hot repositories'
  feed.updated @latest_event.created_at if @latest_event

  @star_events.starred_ranking.each do |repo_name, events, repo|
    feed.entry(
      repo,
      published: repo.created_at,
      updated: events.first.created_at,
      url: github_url(repo.full_name)
    ) do |entry|
      entry.title repo_name
      entry.content(repo.description, type: :html)
    end
  end
end
