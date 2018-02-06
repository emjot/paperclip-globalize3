module Paperclip
  module Globalize3
    module Attachment
      def assign(uploaded_file)
        @file =
          if Paperclip::Attachment.default_options.key?(:adapter_options) # paperclip >= 5.2.0
            Paperclip.io_adapters.for(uploaded_file, @options[:adapter_options])
          else # paperclip < 5.2.0
            Paperclip.io_adapters.for(uploaded_file)
          end
        ensure_required_accessors!
        ensure_required_validations!

        if @file.assignment?
          clear(*only_process, :locales => Globalize.locale) # [paperclip-globalize3] only clear current locale
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
          super(styles)
        end
      end

      # If translated, execute the block for the given locales only (or for all translated locales if none are given).
      # If any locales are given, only those for which a translation exists are used.
      # If attachment is untranslated, simply execute the block.
      def with_locales_if_translated(with_locales = nil)
        if instance.respond_to?(:translated_locales) && instance.translated?(:"#{name}_file_name")
          # TODO: translated_locales are not present any more when this is called via destroy callback
          #   (unless 'translates' is defined AFTER 'has_attached_file' in the model class)
          with_locales =
            if with_locales.nil?
              [*instance.translated_locales]
            else
              [*with_locales] & instance.translated_locales
            end
          Globalize.with_locales(with_locales) { yield }
        else
          yield
        end
      end
    end
  end
end
