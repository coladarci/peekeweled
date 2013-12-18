class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :user, index: true
      t.integer :score
      t.integer :length
      t.text :cells

      t.timestamps
    end
  end
end
