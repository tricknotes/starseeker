require "#{Rails.root}/config/environment"

desc 'Remove old events'
task :remove_old_events do
  WatchEvent.where(created_at: {'$lte' => 9.days.ago.strftime(WatchEvent::DATETIME_FORMAT)}).destroy
end
