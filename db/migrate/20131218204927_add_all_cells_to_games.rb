class AddAllCellsToGames < ActiveRecord::Migration
  def change
    add_column :games, :allCells, :text
  end
end
