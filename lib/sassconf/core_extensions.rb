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

      def newline(count = 1, side = :right, &block)
        base_manipulation("\n", count, side, &block)
      end

      def paragraph(count = 1, side = :right, &block)
        base_manipulation("\n\n", count, side, &block)
      end

      def blank(count = 1, side = :right, &block)
        base_manipulation(' ', count, side, &block)
      end

      module ClassMethods
        def empty
          ''
        end
      end

      def base_manipulation(char, count, side)
        count.times { side == :left ? self.insert(0, char) : self << char }
        self << (block_given? ? yield : '')
      end

      module_function :base_manipulation

    end

    module Hash
      def is_hash?
        true
      end
    end
  end
end

class Object
  include Sassconf::CoreExtensions::Object
end

class String
  include Sassconf::CoreExtensions::String
end

class Hash
  include Sassconf::CoreExtensions::Hash
end