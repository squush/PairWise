class SetDefaultWinnersInTournaments < ActiveRecord::Migration[7.0]
  def change
    change_column_default :tournaments, :number_of_winners, from: nil, to: 0
  end
end
