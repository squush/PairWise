class ChangeDatetimeToDateInEvents < ActiveRecord::Migration[7.0]
  def change
    change_column :events, :datetime, :date
    rename_column :events, :datetime, :date
  end
end
