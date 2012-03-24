class WatchEvent
  include Mongoid::Document
  # TODO enable this
  # default_scope type: 'WatchEvent'

  scope :newly, ->(from) { where(created_at: {'$gte' => from}) }

  def self.watched_lanking
    grouped_events = self.all.group_by {|event| event['repo']['name'] }
    lanking = grouped_events.sort_by {|repo_name, events| -events.count }
    lanking
  end
end
