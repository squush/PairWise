class Player < ApplicationRecord
  belongs_to :tournament
  has_many :matchups
  validates :name, :rating, :division, :crosstables_id, :tournament_id, presence: true
end
