module Sassconf
  class Util
    def self.pre_check(term, message)
      raise ArgumentError, message if !term
    end
  end
end

