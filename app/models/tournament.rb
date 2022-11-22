class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players, dependent: :destroy
  has_many :matchups, through: :players, dependent: :destroy

  validates :rounds, presence: true, numericality: { greater_than: 0 }

  enum pairing_system: {
    swiss: 0,
    round_robin: 1
  }
end
