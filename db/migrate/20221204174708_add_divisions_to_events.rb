class AddDivisionsToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :divisions, :integer, default: 1
  end
end
