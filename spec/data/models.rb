class Post < ActiveRecord::Base
  has_attached_file :image,
                    :url => "/system/:class/:attachment/:id/:locale/:style-:fingerprint.:extension"

  translates :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :image_fingerprint
end

class Untranslated < ActiveRecord::Base
  has_attached_file :image,
                    :url => "/system/:class/:attachment/:id/:style-:fingerprint.:extension"
end

