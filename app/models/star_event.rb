class StarEvent
  include Mongoid::Document
  self.default_collection_name = 'watch_events'
  default_scope where(type: 'WatchEvent')

  DATETIME_FORMAT = '%Y-%m-%dT%TZ'

  scope :latest, ->(from) { where(created_at: {'$gte' => from.strftime(DATETIME_FORMAT)}) }
  scope :newly, order_by([:created_at, :desc])
  scope :all_by, ->(logins) { self.all.any_in('actor.login' => logins ) }
  scope :owner, ->(login) { where('repo.name' => /^#{login}\//) }

  def self.by(login)
    self.where('actor.login' => {'$in' => [login]})
  end

  def self.starred_ranking
    star_events = self.all.newly
    star_events = star_events.uniq {|event| [event['repo']['name'], event['actor']['login']].hash }
    grouped_events = star_events.group_by {|event| event['repo']['name'] }
    grouped_events = grouped_events.sort_by {|repo_name, events| [-events.count, -events.first.created_at.to_i] }
    grouped_events = grouped_events.map do |repo_name, events|
      repo = events.first.repository!
      [repo_name, events, repo]
    end
    grouped_events = grouped_events.select {|repo_name, events, repo| repo }
    grouped_events
  end

  def self.each_with_repo
    self.all.each do |star_event|
      repo = star_event.repository!
      yield star_event, repo if repo
    end
  end

  def repository
    @repository ||= Repository.by_name(repo['name'])
  end

  def repository!
    repository || Repository.fetch!(self.repo['name'])
  end

  def created_at
    self['created_at'].to_datetime
  end
end
