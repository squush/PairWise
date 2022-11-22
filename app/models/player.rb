class Player < ApplicationRecord
  belongs_to :tournament
  validates :name, :rating, :division, :crosstables_id, :tournament_id, presence: true
end
