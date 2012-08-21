namespace :db do
  Dir[Rails.root.join('db', 'seeds_*.rb').to_s].each do |seeds_path|
    desc 'Load the seed data from db/%s' % File.basename(seeds_path)
    task File.basename(seeds_path, '.rb') => :environment do
      load seeds_path
    end
  end
end
