class Tournament < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true
  has_many :players, dependent: :destroy
  has_many :matchups, through: :players, dependent: :destroy

  enum status: {
    swiss: 0,
    round_robin: 1
  }
end
