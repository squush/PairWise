class Event < ApplicationRecord
  # TODO: Strictly speaking, this doesn't need an association. Long-term, maybe
  #       it makes sense to lock an event from having more than one tournament
  #       created using a has_one association, but that would likely need some
  #       type of official validation with NASPA.
end
