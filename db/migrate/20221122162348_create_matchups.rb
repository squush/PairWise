class CreateMatchups < ActiveRecord::Migration[7.0]
  def change
    create_table :matchups do |t|
      t.integer :round_number
      t.integer :player1_score
      t.integer :player2_score
      # t.references :player1, null: false, foreign_key: true
      # t.references :player2, null: false, foreign_key: true
      t.references :player1, null: false, foreign_key: { to_table: 'players' }
      t.references :player2, null: false, foreign_key: { to_table: 'players' }

      t.timestamps
    end
  end
end
