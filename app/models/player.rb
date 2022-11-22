class Player < ApplicationRecord
  belongs_to :tournament
  has_many :matchups, dependent: :destroy
end
