# Support for models that attach a user photo via
#   has_one_attached :photo

module HasUserPhoto
  extend ActiveSupport::Concern

  def attach_photo(user_photo)
    photo.attach(io: user_photo, filename: "player_pic.jpg", content_type: "image/jpg")
  end

  def attach_default_photo
    default = "user-astronaut-solid.svg"
    default_pic = File.open("app/assets/images/#{default}")
    photo.attach(io: default_pic, filename: default, content_type: "image/svg+xml")
  end
end
