class GenerateFeedTokenToUsers < ActiveRecord::Migration
  def up
    User.all.each(&:save!)
  end
end
