class Player < ApplicationRecord
  belongs_to :tournament
  # TODO: Figure out how to get dependent: :destroy working with destroy_all in
  #       the seed. Currently it causes an error because (I think) the matchups
  #       have two foreign keys to the players table. Probably need a ticket.
  has_many :matchups#, dependent: :destroy

  validates :name, :rating, :division, presence: true
end
