class Player < ApplicationRecord
  belongs_to :tournament
  has_many :matchups
end
