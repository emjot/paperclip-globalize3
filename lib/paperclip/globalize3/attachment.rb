# frozen_string_literal: true

module Paperclip
  module Globalize3
    # Prepend to the paperclip `Attachment` class to transparently read and write
    # your attachments in context of the current locale using globalize.
    #
    # E.g. `my_model.my_attachment` returns a different attachment when your
    # current locale is 'en' compared to when your current locale is 'de'.
    #
    # Requires a :locale interpolation for your paperclip attachment(s) and the
    # respective columns to be translated.
    module Attachment
      def assign(uploaded_file)
        @file = Paperclip.io_adapters.for(uploaded_file, @options[:adapter_options])
        ensure_required_accessors!
        ensure_required_validations!

        if @file.assignment?
          clear(*only_process, locales: Globalize.locale) # [paperclip-globalize3] only clear current locale
          if @file.nil?
            nil
          else
            assign_attributes
            post_process_file
            reset_file_if_original_reprocessed
          end
        else
          nil
        end
      end

      def clear(*args)
        options = args.extract_options!
        styles_to_clear = args
        if styles_to_clear.any?
          queue_some_for_delete(*styles_to_clear, options)
        else
          queue_all_for_delete(options)
          @queued_for_write  = {}
          @errors            = {}
        end
      end

      private

      def queue_all_for_delete(options = {}) #:nodoc:
        with_locales_if_translated(options[:locales]) do
          super()
        end
      end

      def queue_some_for_delete(*args)
        options = args.extract_options!
        styles  = args
        with_locales_if_translated(options[:locales]) do
          super(*styles)
        end
      end

      # Yields the given block in context of Globalize#with_locales, but handles these situations gracefully:
      #
      # * if it is not translated (=> then don't use Globalize)
      # * if there are no locales given (=> then use all translated locales)
      # * if there are `with_locales` requested for which there are no translations (=> then skip those)
      #
      # @param [Symbol, Array[Symbol], nil] with_locales only yield block for these translated locales
      def with_locales_if_translated(with_locales = nil)
        if translated?
          locales = with_locales.nil? ? translated_locales : [*with_locales] & translated_locales
          Globalize.with_locales(locales) { yield }
        else
          yield
        end
      end

      # Whether both the model and the attachment are translated
      def translated?
        instance.respond_to?(:translated_locales) && instance.translated?(:"#{name}_file_name")
      end

      # Returns the locales for which there are translations for the model instance, if applicable
      # (nil if the model or the attachment is not translated).
      #
      # @return [Array[Symbol], nil]
      def translated_locales
        return unless translated?

        # TODO: translated_locales are not present any more when this is called via destroy callback
        #   (unless 'translates' is defined AFTER 'has_attached_file' in the model class)
        instance.translated_locales
      end
    end
  end
end
