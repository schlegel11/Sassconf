module Sassconf
  class Util
    def self.pre_check(term, message)
      raise ArgumentError, message unless term
    end
  end
end

