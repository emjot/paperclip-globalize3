module Paperclip
  module Globalize3
    module Attachment

      def self.included(base)
        base.send :include, InstanceMethods
        base.send :alias_method_chain, :assign, :globalize3
        base.send :alias_method_chain, :clear, :globalize3
        base.send :alias_method_chain, :queue_existing_for_delete, :globalize3
      end

      module InstanceMethods

        def assign_with_globalize3(uploaded_file)
          ensure_required_accessors!

          if uploaded_file.is_a?(Paperclip::Attachment)
            uploaded_filename = uploaded_file.original_filename
            uploaded_file = uploaded_file.to_file(:original)
            close_uploaded_file = uploaded_file.respond_to?(:close)
          else
            instance_write(:uploaded_file, uploaded_file) if uploaded_file
          end

          return nil unless valid_assignment?(uploaded_file)

          uploaded_file.binmode if uploaded_file.respond_to? :binmode
          self.clear(Globalize.locale) # [paperclip-globalize3] only clear current locale

          return nil if uploaded_file.nil?

          uploaded_filename ||= uploaded_file.original_filename
          stores_fingerprint             = @instance.respond_to?("#{name}_fingerprint".to_sym)
          @queued_for_write[:original]   = to_tempfile(uploaded_file)
          instance_write(:file_name,       cleanup_filename(uploaded_filename.strip))
          instance_write(:content_type,    uploaded_file.content_type.to_s.strip)
          instance_write(:file_size,       uploaded_file.size.to_i)
          instance_write(:fingerprint,     generate_fingerprint(uploaded_file)) if stores_fingerprint
          instance_write(:updated_at,      Time.now)

          @dirty = true

          post_process(*@options[:only_process]) if post_processing

          # Reset the file size if the original file was reprocessed.
          instance_write(:file_size,   @queued_for_write[:original].size.to_i)
          instance_write(:fingerprint, generate_fingerprint(@queued_for_write[:original])) if stores_fingerprint
        ensure
          uploaded_file.close if close_uploaded_file
        end


        def clear_with_globalize3(with_locales = nil)
          queue_existing_for_delete(with_locales)
          @queued_for_write  = {}
          @errors            = {}
        end

        private

        def queue_existing_for_delete_with_globalize3(with_locales = nil) #:nodoc:
          if instance.respond_to?(:translated_locales) && instance.translated?(:"#{name}_file_name")
            # do it for the given locales only (or for all translated locales if none are given)
            with_locales = instance.translated_locales if with_locales.nil?
            Globalize.with_locales([*with_locales]) { queue_existing_for_delete_without_globalize3 }
          else
            queue_existing_for_delete_without_globalize3
          end
        end

      end

    end
  end
end
