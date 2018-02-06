require 'paperclip/globalize3/version'
require 'paperclip/globalize3/attachment'

require 'globalize'
require 'paperclip'

# Paperclip locale interpolation: if locale fallbacks are used, we need to determine & use the fallback locale
Paperclip.interpolates(:locale) do |attachment, _style_name|
  record = attachment.instance
  file_name_attr = "#{attachment.name}_file_name"
  attachment_locale =
    if record.respond_to?(:translation) && record.translated?(file_name_attr)
      # determine via metadata if activated (I18n::Backend::Simple.include(I18n::Backend::Metadata))
      if record.send(file_name_attr).respond_to?(:translation_metadata)
        record.send(file_name_attr).translation_metadata[:locale]
      else # determine via globalize fallback configuration
        (record.globalize_fallbacks(Globalize.locale) & record.translated_locales).first # (nil if record is new)
      end
    else
      Rails.logger.warn(
        "WARN You have used :locale in a paperclip url/path for an untranslated model (in #{record.class})."
      )
      nil
    end
  (attachment_locale || Globalize.locale).to_s
end

unless Paperclip::Attachment.instance_methods.include?(:assign_attributes)
  Paperclip::Attachment.send(:include, Paperclip::Globalize3::Attachment::Compatibility::Paperclip41)
end

Paperclip::Attachment.send(:include, Paperclip::Globalize3::Attachment)
