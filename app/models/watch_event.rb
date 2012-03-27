class WatchEvent
  include Mongoid::Document
  # TODO enable this
  # default_scope type: 'WatchEvent'

  DATETIME_FORMAT = '%Y-%m-%dT%TZ'

  scope :latest, ->(from) { where(created_at: {'$gte' => from.strftime(DATETIME_FORMAT)}) }

  def self.watched_ranking
    grouped_events = self.all.group_by {|event| event['repo']['name'] }
    grouped_events.sort_by {|repo_name, events| -events.count }
  end

  def self.all_by(logins)
    self.all.any_in('actor.login' => logins )
  end

  def self.with(login)
    self.all.also_in('actor.login' => [login])
  end

  def created_at
    self['created_at'].to_datetime
  end
end
