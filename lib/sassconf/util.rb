module Sassconf
  class Util
    def self.pre_check(term, message)
      raise ArgumentError, message unless term
    end

    #Credits go to https://github.com/rdp/os
    def self.windows?
        if RUBY_PLATFORM =~ /cygwin/ # i386-cygwin
          false
        elsif ENV['OS'] == 'Windows_NT'
          true
        else
          false
        end
      end
  end
end

