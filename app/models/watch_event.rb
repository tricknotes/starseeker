class WatchEvent
  include Mongoid::Document
  default_scope where(type: 'WatchEvent')

  DATETIME_FORMAT = '%Y-%m-%dT%TZ'

  scope :latest, ->(from) { where(created_at: {'$gte' => from.strftime(DATETIME_FORMAT)}) }
  scope :newly, order_by([:created_at, :desc])
  scope :all_by, ->(logins) { self.all.any_in('actor.login' => logins ) }
  scope :owner, ->(login) { where('repo.name' => /^#{login}\//) }

  def self.by(login)
    self.all.also_in('actor.login' => [login])
  end

  def self.watched_ranking
    grouped_events = self.all.group_by {|event| event['repo']['name'] }
    grouped_events = grouped_events.sort_by {|repo_name, events| -events.count }
    grouped_events = grouped_events.map do |repo_name, events|
      repo = events.first.repository!
      [repo_name, events, repo]
    end
    grouped_events = grouped_events.select {|repo_name, events, repo| repo }
    grouped_events
  end

  def self.each_with_repo
    self.all.each do |watch_event|
      repo = watch_event.repository!
      yield watch_event, repo if repo
    end
  end

  def repository
    @repository ||= Repository.where(id: self.repo['id']).first
  end

  def repository!
    repository || Repository.fetch!(self.repo['name'])
  end

  def created_at
    self['created_at'].to_datetime
  end
end
