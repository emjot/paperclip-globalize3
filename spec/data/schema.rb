ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :posts, :force => true do |t|
    t.integer    :rating
  end

  create_table :post_translations, :force => true do |t|
    t.string     :locale
    t.references :post
    t.string     :image_file_name
    t.integer    :image_file_size
    t.string     :image_content_type
    t.string     :image_fingerprint
    t.timestamp  :image_updated_at
  end

  create_table :untranslateds, :force => true do |t|
    t.string     :image_file_name
    t.integer    :image_file_size
    t.string     :image_content_type
    t.string     :image_fingerprint
    t.timestamp  :image_updated_at
  end

end