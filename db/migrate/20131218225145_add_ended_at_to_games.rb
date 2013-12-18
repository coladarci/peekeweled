class AddEndedAtToGames < ActiveRecord::Migration
  def change
    add_column :games, :ended_at, :datetime
  end
end
