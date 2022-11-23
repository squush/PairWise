class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players, dependent: :destroy
  has_many :matchups, through: :players, source: :matchups_as_player1

  validates :rounds, presence: true, numericality: { greater_than: 0 }
  # TODO: Possibly need a validation for number_of_winners, but low priority

  enum pairing_system: {
    swiss: 10,
    round_robin: 20
  }
end
