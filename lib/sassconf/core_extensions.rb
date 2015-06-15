module Sassconf
  module CoreExtensions
    module Object
      def self.def_false(*args)
        raise ArgumentError, 'Argument is not a symbol' unless args.all? { |arg| arg.is_a?(Symbol) }
        args.each { |arg| alias_method arg, :false_ }
      end

      def false_
        false
      end
    end

    Object.def_false(:string?, :hash?, :boolean?, :integer?, :array?, :not_nil_or_empty?)

    module String
      def self.included(base)
        base.extend(ClassMethods)
      end

      def string?
        true
      end

      def not_nil_or_empty?
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

        def newline(count = 1, side = :left, &block)
          new.newline(count, side, &block)
        end

        def paragraph(count = 1, side = :left, &block)
          new.paragraph(count, side, &block)
        end

        def blank(count = 1, side = :left, &block)
          new.blank(count, side, &block)
        end
      end

      def base_manipulation(char, count, side)
        count.times { side == :left ? self.insert(0, char) : self << char }
        self << (block_given? ? yield : '')
      end

      module_function :base_manipulation
    end

    module Hash
      def hash?
        true
      end
    end

    module Array
      def array?
        true
      end
    end

    module Boolean
      def boolean?
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

class Array
  include Sassconf::CoreExtensions::Array
end

class TrueClass
  include Sassconf::CoreExtensions::Boolean
end

class FalseClass
  include Sassconf::CoreExtensions::Boolean
end