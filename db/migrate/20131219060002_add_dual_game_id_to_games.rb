class AddDualGameIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :dual_id, :integer
  end
end
