require "#{Rails.root}/config/environment"

desc 'Remove old events'
task :remove_old_events do
  StarEvent.where(created_at: {'$lte' => 9.days.ago.strftime(StarEvent::DATETIME_FORMAT)}).delete_all
end
