module Settings
  # Settings for a tournament.
  #
  # A Tournament has a PairingSystem serialized into a json field

  RoundPairing = Struct.new(:round, :start_round, :strategy)

  PairingSystem = Struct.new(:round_pairings) do

    def add_round_pairing(round, start_round, strategy)
      # Pair round {round} based on applying {strategy} to {start_round}
      round_pairings[round] = RoundPairing.new(round, start_round, strategy)
    end

    class << self
      # ActiveRecord serialization support

      def dump(value)
        PairingSystemMapper.to_json(value)
      end

      def load(value)
        # tournament.pairing_system defaults to "", so we need to check for
        # either a null value or an empty string in the db.
        if value.nil? || value.empty?
          PairingSystem.new([])
        else
          PairingSystemMapper.from_json(value)
        end
      end
    end
  end

  # -------------------------------------
  # Shale mappers to convert to/from json

  class RoundPairingMapper < Shale::Mapper
    model RoundPairing

    attribute :round, Shale::Type::Integer
    attribute :strategy, Shale::Type::Integer
  end

  class PairingSystemMapper < Shale::Mapper
    model PairingSystem

    attribute :round_pairings, RoundPairingMapper, collection: true
  end
end
