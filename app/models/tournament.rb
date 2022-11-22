class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players
  has_many :matchups, through: :players
  validates :pairing_system, :event_id, presence: true
  validates :rounds, presence: true, numericality: { greater_than_or_equal_to: 1 }
end
