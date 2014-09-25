module Paperclip
  module Globalize3
    module Attachment

      def self.included(base)
        base.send :include, InstanceMethods
        base.send :alias_method_chain, :assign, :globalize3
        base.send :alias_method_chain, :clear, :globalize3
        base.send :alias_method_chain, :queue_all_for_delete, :globalize3
        base.send :alias_method_chain, :queue_some_for_delete, :globalize3
      end

      module InstanceMethods
        def assign_with_globalize3(uploaded_file)
          @file = Paperclip.io_adapters.for(uploaded_file)
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

        def clear_with_globalize3(*args)
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

        def queue_all_for_delete_with_globalize3(options = {}) #:nodoc:
          with_locales_if_translated(options[:locales]) do
            queue_all_for_delete_without_globalize3
          end
        end

        def queue_some_for_delete_with_globalize3(*args)
          options = args.extract_options!
          styles = args
          with_locales_if_translated(options[:locales]) do
            queue_some_for_delete_without_globalize3(styles)
          end
        end

        # If translated, execute the block for the given locales only (or for all translated locales if none are given).
        # Otherwise, simply execute the block.
        def with_locales_if_translated(with_locales = nil, &block)
          if instance.respond_to?(:translated_locales) && instance.translated?(:"#{name}_file_name")
            # TODO translated_locales are not present any more when this is called via destroy callback (unless 'translates' is defined AFTER 'has_attached_file' in the model class)
            with_locales = instance.translated_locales if with_locales.nil?
            Globalize.with_locales([*with_locales]) { yield }
          else
            yield
          end
        end
      end

      module Compatibility
        # The paperclip-globalize3 patches are based on paperclip 4.2 code;
        # this module needs to be included when trying to use with paperclip 4.1.
        module Paperclip41
          def assign_attributes
            @queued_for_write[:original] = @file
            assign_file_information
            assign_fingerprint(@file.fingerprint)
            assign_timestamps
          end

          def assign_file_information
            instance_write(:file_name, cleanup_filename(@file.original_filename))
            instance_write(:content_type, @file.content_type.to_s.strip)
            instance_write(:file_size, @file.size)
          end

          def assign_fingerprint(fingerprint)
            if instance_respond_to?(:fingerprint)
              instance_write(:fingerprint, fingerprint)
            end
          end

          def assign_timestamps
            if has_enabled_but_unset_created_at?
              instance_write(:created_at, Time.now)
            end

            instance_write(:updated_at, Time.now)
          end

          def post_process_file
            dirty!

            if post_processing
              post_process(*only_process)
            end
          end

          def dirty!
            @dirty = true
          end

          def reset_file_if_original_reprocessed
            instance_write(:file_size, @queued_for_write[:original].size)
            assign_fingerprint(@queued_for_write[:original].fingerprint)
            reset_updater
          end

          def reset_updater
            if instance.respond_to?(updater)
              instance.send(updater)
            end
          end

          def updater
            :"#{name}_file_name_will_change!"
          end
        end
      end

    end
  end
end
