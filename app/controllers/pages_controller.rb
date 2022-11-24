class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  # TODO: Remove if we don't add this feature
  def contact_us
  end

  # TODO: Remove if we don't add this feature. This might also belong under a
  #       users controller instead.
  def my_profile
  end
end
