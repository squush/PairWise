class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players, dependent: :destroy
  has_many :matchups, through: :players, dependent: :destroy
end
