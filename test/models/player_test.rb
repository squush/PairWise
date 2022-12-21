require "test_helper"

class PlayerTest < ActiveSupport::TestCase
  test "bye" do
    p = build(:bye_player)
    assert p.bye?
  end
end
