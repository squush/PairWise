FactoryBot.define do
  factory :user do
    email { "email@test.com" }
    password { "hunter2" }
  end

  factory :event

  factory :tournament do
    user
    event
    location { "somewhere" }
    date { Date.today }
    rounds { 4 }
  end

  factory :player do
    tournament
    sequence(:name) {|n| "Player #{n}"}
    sequence(:rating) {|n| 2400 - 50 * n}
    sequence(:ranking)
    division { 1 }

    factory :bye_player do
      name { "Bye" }
    end
  end

  factory :matchup do
    player1 factory: :player
    player2 factory: :player
  end
end
