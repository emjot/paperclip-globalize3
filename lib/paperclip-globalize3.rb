require "paperclip/globalize3/version"
require "paperclip/globalize3/attachment"

require "globalize"
require "paperclip"

Paperclip.interpolates(:locale) { |attachment, _|
  attachment.instance.send("#{attachment.name}_file_name").translation_metadata[:locale]
}

unless Paperclip::Attachment.instance_methods.include?(:only_process)
  Paperclip::Attachment.send(:include, Paperclip::Globalize3::Attachment::Compatibility::Paperclip33)
end

Paperclip::Attachment.send(:include, Paperclip::Globalize3::Attachment)
