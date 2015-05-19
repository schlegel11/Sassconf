require_relative 'util'

module Sassconf
  module CoreExtensions
    module Object
      def is_string?
        false
      end

      def is_hash?
        false
      end
    end

    module String
      def self.included(base)
        base.extend(ClassMethods)
      end

      def is_string?
        true
      end

      def is_not_nil_or_empty?
        !(self.nil? || self.empty?)
      end

      def newline(count = 1, side = :right)
        count.times { side == :left ? self.insert(0, "\n") : self << "\n" }
        self << (block_given? ? yield : '')
      end

      def paragraph(count = 1, side = :right)
        count.times { side == :left ? self.insert(0, "\n\n") : self << "\n\n" }
        self << (block_given? ? yield : '')
      end

      def blank(count = 1, side = :right)
        count.times { side == :left ? self.insert(0, ' ') : self << ' ' }
        self << (block_given? ? yield : '')
      end

      module ClassMethods
        def empty
          ''
        end
      end
    end

    module Hash
      def is_hash?
        true
      end
    end
  end

  Object.include(Sassconf::CoreExtensions::Object)
  String.include(Sassconf::CoreExtensions::String)
  Hash.include(Sassconf::CoreExtensions::Hash)
end