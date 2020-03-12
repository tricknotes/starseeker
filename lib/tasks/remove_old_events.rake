desc 'Remove old events'
task :remove_old_events => :environment do
  max_old_day = Integer(ENV['KEEP_MAX_OLD_EVENT_DAY'] || 7)
  StarEvent.where(created_at: {'$lte' => max_old_day.days.ago.strftime(StarEvent::DATETIME_FORMAT)}).delete_all
end
