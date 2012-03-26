class WatchEvent
  include Mongoid::Document
  # TODO enable this
  # default_scope type: 'WatchEvent'

  DATETIME_FORMAT = '%Y-%m-%dT%TZ'

  scope :newly, ->(from) { where(created_at: {'$gte' => from.strftime(DATETIME_FORMAT)}) }

  def self.watched_lanking
    grouped_events = self.all.group_by {|event| event['repo']['name'] }
    lanking = grouped_events.sort_by {|repo_name, events| -events.count }
    lanking
  end

  def self.with(login)
    self.all.also_in('actor.login' => [login])
  end

  def created_at
    self['created_at'].to_datetime
  end
end
