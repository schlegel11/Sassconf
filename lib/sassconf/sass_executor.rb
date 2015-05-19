require_relative 'util'
require_relative 'core_extensions'
require_relative 'logger'

module Sassconf
  class SassExecutor
    include Logging

    SASS_PROCESS = 'sass %s %s %s'
    SASS_VALUE_ARGUMENT = '--%s=%s '
    SASS_ARGUMENT = '--%s %s '

    def initialize(sass_input, sass_output)
      @sass_input = sass_input
      @sass_output = sass_output
    end

    def create_argument_with_value_string(argument_hash)
      create_string(SASS_VALUE_ARGUMENT, argument_hash)
    end

    def create_argument_string(argument_hash)
      create_string(SASS_ARGUMENT, argument_hash)
    end

    def create_all_argument_strings(argument_value_hash, argument_hash)
      create_argument_with_value_string(argument_value_hash).concat(' ').concat(create_argument_string(argument_hash))
    end

    def execute(argument_string)
      Util.pre_check((argument_string.is_string? and argument_string.is_not_nil_or_empty?), 'Argument string is no string, nil or empty.')

      system(SASS_PROCESS % [argument_string, @sass_input, @sass_output])
    end

    private
    def create_string(argument_type, argument_hash)
      Util.pre_check(argument_type.is_string?, 'Argument type is no string.')
      Util.pre_check((argument_hash.is_hash? and !argument_hash.nil?), 'Argument hash is no hash or nil.')

      logger.info("Create argument string from hash: #{argument_hash}")
      argument_hash.each { |key, value| argument_hash[key] = String.empty if value == :no_value }
      argument_hash.reduce('') { |arg_string, (key, value)| arg_string.concat((argument_type % [key, value])) }.strip
    end
  end
end