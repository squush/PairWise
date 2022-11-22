class CreateTournaments < ActiveRecord::Migration[7.0]
  def change
    create_table :tournaments do |t|
      t.string :location
      t.datetime :datetime
      t.integer :rounds
      t.integer :number_of_winners
      t.integer :pairing_system
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end
  end
end
