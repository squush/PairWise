require_relative '../lib/crosstables_fetcher'

class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in? && !current_user.photo.attached?
      if current_user.crosstables_id
        user_photo = CrosstablesFetcher.get_player_photo(current_user.crosstables_id)
        current_user.photo.attach(io: user_photo, filename: "user_pic.jpg", content_type: "image/jpg")
        current_user.save
      else
        current_user.photo.attach(io: File.open('app/assets/images/user-astronaut-solid.svg'), filename: "user-astronaut-solid.svg", content_type: "image/svg+xml")
        current_user.save
      end
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
