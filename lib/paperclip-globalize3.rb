require "paperclip/globalize3/version"
require "paperclip/globalize3/attachment"

require "globalize"
require "paperclip"

Paperclip.interpolates(:locale) { |_, _| Globalize.locale.to_s }

unless Paperclip::Attachment.instance_methods.include?(:only_process)
  Paperclip::Attachment.send(:include, Paperclip::Globalize3::Attachment::Compatibility::Paperclip33)
end

Paperclip::Attachment.send(:include, Paperclip::Globalize3::Attachment)
