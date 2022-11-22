class Player < ApplicationRecord
  belongs_to :tournament
  has_many :matchups, dependent: :destroy

  validates :name, :rating, :division, presence: true
end
