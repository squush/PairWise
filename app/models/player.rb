class Player < ApplicationRecord
  belongs_to :tournament
  has_many :matchups
  validates :name, :rating, :division, presence: true
end
