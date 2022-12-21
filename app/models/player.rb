class Player < ApplicationRecord
  belongs_to :tournament
  # The foreign_key in the lines below ensures the destroy works. Otherwise it's
  # looking for just "player_id" by default.
  has_many :matchups_as_player1, class_name: "Matchup", dependent: :destroy, foreign_key: :player1_id
  has_many :matchups_as_player2, class_name: "Matchup", dependent: :destroy, foreign_key: :player2_id
  has_one_attached :photo
  # TODO: Validation for seed?
  validates :name, :rating, :division, presence: true
  validates :spread, presence: true, numericality: { only_integer: true }
  validates :win_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :loss_count, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :for_division, ->(division) { where(division: division) }
  scope :non_bye, -> { where("name != 'Bye'") }
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  def bye?
    name == "Bye"
  end

  def recalculate
    results = PlayerResult.for_player(self)
    self.win_count = results.map(&:wins).sum
    self.loss_count = results.map(&:losses).sum
    self.spread = results.map(&:spread).sum
  end
end
