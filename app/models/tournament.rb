class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players
  has_many :matchups, through: :players
  # TODO: set default value of swiss for pairing_system
  validates :rounds, presence: true, numericality: { greater_than: 0 }
end
