class ChangeDatetimeToDateInTournaments < ActiveRecord::Migration[7.0]
  def change
    change_column :tournaments, :datetime, :date
    rename_column :tournaments, :datetime, :date
  end
end
