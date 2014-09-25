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
          ensure_required_accessors!
          file = Paperclip.io_adapters.for(uploaded_file)

          return nil if file.respond_to?(:assignment?) && !file.assignment?
          self.clear(*only_process, :locales => Globalize.locale) # [paperclip-globalize3] only clear current locale
          return nil if file.nil?

          @queued_for_write[:original]   = file
          instance_write(:file_name,       cleanup_filename(file.original_filename))
          instance_write(:content_type,    file.content_type.to_s.strip)
          instance_write(:file_size,       file.size)
          instance_write(:fingerprint,     file.fingerprint) if instance_respond_to?(:fingerprint)
          instance_write(:created_at,      Time.now) if has_enabled_but_unset_created_at?
          instance_write(:updated_at,      Time.now)

          @dirty = true

          if post_processing &&
              (file.respond_to?(:assignment?) || valid_assignment?)
            post_process(*only_process)
          end

          instance_write(:file_size,   @queued_for_write[:original].size)
          instance_write(:fingerprint, @queued_for_write[:original].fingerprint) if instance_respond_to?(:fingerprint)
          updater = :"#{name}_file_name_will_change!"
          instance.send updater if instance.respond_to? updater
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

    end
  end
end
