class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  # TODO: Figure out how to get dependent: :destroy working with destroy_all in
  #       the seed. Currently it causes an error because (I think) the matchups
  #       have two foreign keys to the players table. Probably need a ticket.
  has_many :players#, dependent: :destroy
  has_many :matchups, through: :players #, dependent: :destroy

  validates :rounds, presence: true, numericality: { greater_than: 0 }
  # TODO: Possibly need a validation for number_of_winners, but low priority

  enum pairing_system: {
    swiss: 10,
    round_robin: 20
  }
end
