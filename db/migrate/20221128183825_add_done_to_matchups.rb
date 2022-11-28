class AddDoneToMatchups < ActiveRecord::Migration[7.0]
  def change
    add_column :matchups, :done, :boolean, default: false
  end
end
