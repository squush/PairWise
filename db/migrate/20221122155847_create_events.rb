class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :location
      t.datetime :datetime
      t.integer :rounds

      t.timestamps
    end
  end
end
