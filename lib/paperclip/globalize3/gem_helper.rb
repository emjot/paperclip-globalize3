# frozen_string_literal: true

module Paperclip
  module Globalize3
    # Like Bundler::GemHelper, but tags versions without the 'v' prefix (e.g. '1.0.0' instead of 'v1.0.0')
    class GemHelper < Bundler::GemHelper
      protected

      def version_tag
        version.to_s
      end
    end
  end
end
