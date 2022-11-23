class AddXtablesIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :xtables_id, :integer
  end
end
