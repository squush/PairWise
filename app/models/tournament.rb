class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players, dependent: :destroy
  has_many :matchups, through: :players, source: :matchups_as_player1

  validates :number_of_winners, presence: true

  enum pairing_system: {
    "Swiss" => 10,
    "Round Robin" => 20
  }
end
