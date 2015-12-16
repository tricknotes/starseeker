desc 'Remove old events'
task :remove_old_events => :environment do
  StarEvent.where(created_at: {'$lte' => 7.days.ago.strftime(StarEvent::DATETIME_FORMAT)}).delete_all
end
