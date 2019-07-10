class BasePost < ActiveRecord::Base
  self.table_name = 'posts'
end

class Post < BasePost
  has_attached_file :image,
    url: '/system/:test_env_number/:class/:attachment/:id/:locale/:style-:fingerprint.:extension'
  validates_attachment :image, content_type: {content_type: ['image/png']}

  translates :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :image_fingerprint
end

class PostWithStyles < BasePost
  has_attached_file :image,
    url:    '/system/:test_env_number/:class/:attachment/:id/:locale/:style-:fingerprint.:extension',
    styles: {thumb: '10x10', large: '40x40'}
  validates_attachment :image, content_type: {content_type: ['image/png']}

  translates :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :image_fingerprint
end

class OnlyProcessPost < BasePost
  has_attached_file :image,
    url:          '/system/:test_env_number/:class/:attachment/:id/:locale/:style-:fingerprint.:extension',
    styles:       {thumb: '10x10', large: '40x40'},
    only_process: [:thumb]
  validates_attachment :image, content_type: {content_type: ['image/png']}

  translates :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :image_fingerprint
end

class Untranslated < ActiveRecord::Base
  has_attached_file :image,
    url: '/system/:test_env_number/:class/:attachment/:id/:style-:fingerprint.:extension'
  validates_attachment :image, content_type: {content_type: ['image/png']}
end
