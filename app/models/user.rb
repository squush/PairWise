class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :tournaments, dependent: :destroy
  has_one_attached :photo
  validates :crosstables_id, uniqueness: true, allow_blank: true, allow_nil: true
  # TODO: May also want to associate players and matchups for getting historical
  #       stats for past tournaments. But that's not needed for the basic app.
end
