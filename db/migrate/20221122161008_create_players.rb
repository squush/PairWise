class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :name
      t.integer :rating
      t.integer :ranking
      t.integer :win_count
      t.integer :division
      t.integer :crosstables_id
      t.references :tournament, null: false, foreign_key: true

      t.timestamps
    end
  end
end
