class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # TODO: Figure out how to get dependent: :destroy working with destroy_all in
  #       the seed. Currently it causes an error because (I think) the matchups
  #       have two foreign keys to the players table. Probably need a ticket.
  has_many :tournaments#, dependent: :destroy
  # TODO: May also want to associate players and matchups for getting historical
  #       stats for past tournaments. But that's not needed for the basic app.
end
