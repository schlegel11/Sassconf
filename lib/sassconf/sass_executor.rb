require 'open3'
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
      Util.pre_check((argument_string.string? and argument_string.not_nil_or_empty?), 'Argument string is no string, nil or empty.')

      @pid = spawn(SASS_PROCESS % [argument_string, @sass_input, @sass_output])
      logger.info("Spawn Sass process: #{@pid}")
    end

    def detach_and_kill
      if @pid.integer? && Util.process_exists?(@pid)
        logger.info("Detach Sass process: #{@pid}")
        Process.detach(@pid)

        logger.info("Kill process: #{@pid}")
        Process.kill('KILL', @pid)

        Util.process_childs(@pid) do |pid|
          Process.kill('KILL', pid)
          logger.info("Killed child process: #{pid}")
        end
      end
    end

    def wait
      logger.info("Wait for Sass process: #{@pid}")
      Process.wait(@pid) if @pid.integer? && Util.process_exists?(@pid)
    end

    private
    def create_string(argument_type, argument_hash)
      Util.pre_check(argument_type.string?, 'Argument type is no string.')
      Util.pre_check(argument_hash.hash?, 'Argument hash is no hash.')

      logger.info("Create argument string from hash: #{argument_hash}")
      argument_hash.each { |key, value| argument_hash[key] = String.empty if value == :no_value }
      argument_hash.reduce('') { |arg_string, (key, value)| arg_string.concat((argument_type % [key, value])) }.strip
    end
  end
end

