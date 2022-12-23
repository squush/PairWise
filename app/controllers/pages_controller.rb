require_relative '../lib/crosstables_fetcher'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in? && !current_user.photo.attached?
      if current_user.crosstables_id
        user_photo = CrosstablesFetcher.get_player_photo(current_user.crosstables_id)
        current_user.attach_photo(user_photo)
      else
        current_user.attach_default_photo
      end
      current_user.save
    end
  end

  # TODO: Remove if we don't add this feature
  def contact_us
  end

  # TODO: Remove if we don't add this feature. This might also belong under a
  #       users controller instead.
  def my_profile
  end
end
