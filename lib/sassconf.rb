require 'sassconf/version'
require 'sassconf/config_manager'
require 'sassconf/sass_executor'
require 'optparse'
require 'ostruct'
require 'filewatcher'

module Sassconf
  extend Logging

  class Parser

    module HelpText
      USAGE = 'Usage: sassconf [options] [INPUT] [OUTPUT]'.paragraph
      DESCRIPTION = 'Description:'
                        .newline.blank(3) { 'Adds configuration file to Sass preprocessor.' }
                        .newline.blank(3) { "Version #{Sassconf::VERSION}" }
                        .newline.blank(3) { 'Homepage: http://sassconf.schlegel11.de' }
                        .newline.blank(3) { 'Email: develop@schlegel11.de' }
                        .paragraph
      REQUIRED = 'Required:'
      OPTIONAL = 'Optional:'.newline(1, :left)
    end


    def self.parse(options)

      option_args = OpenStruct.new
      option_args.config_path = String.empty
      option_args.extern_args = String.empty
      option_args.reload_active = false

      opt_parser = OptionParser.new do |opts|
        opts.banner = HelpText::USAGE
        opts.separator(HelpText::DESCRIPTION)
        opts.separator(HelpText::REQUIRED)

        opts.on('-c', '--config CONFIG_FILE ', String, 'Specify a ruby config file e.g.: ', '/PATH/config.rb') do |elem|
          option_args.config_path = elem
        end

        opts.separator(HelpText::OPTIONAL)
        opts.on('-a', '--args ARGS', String, 'Comma separated list of values e.g.:', 'val_a, val_b,...'.paragraph) do |elem|
          option_args.extern_args = elem
        end

        opts.on('-r', '--reload', 'Watch config file for changes and reload it.', 'Useful if you are using "arg_watch" in your config.'.paragraph) do
          option_args.reload_active = true
        end

        opts.on('-v', '--verbose', 'Print all log messages.') do
          Sassconf::Logging.activate
        end

        opts.on('-?', '-h', '--help', 'Show this help. "Wow you really need this help?! ... Me too. ;)"') do
          puts opts
          exit
        end
      end

      opt_parser.parse!(options)

      if option_args.config_path.empty?
        puts opt_parser
        exit
      end
      return option_args
    end
  end

  def self.start
    begin
      cmd_check
      @@option_args = Parser.parse(ARGV)
      @@config_manager = ConfigManager.new
      @@executor = SassExecutor.new(ARGV[0], ARGV[1])

      eval_and_execute
      live_reload(@@option_args.reload_active)
      @@executor.wait
    rescue StandardError, ScriptError => e
      puts e.message
      logger.error(e)
    ensure
      @@executor.detach_and_kill
      exit
    end
  end

  def live_reload(activate)
    Util.pre_check(activate.boolean?, 'Activate is no boolean type.')
    if (activate)
      @@config_manager.watch_update(@@option_args.config_path) do |filename|
        begin
          logger.info("Config reload: #{filename}")
          eval_and_execute
          puts "Config reloaded: #{filename}".newline(1, :left).paragraph
        rescue StandardError, ScriptError => e
          puts e.message
          logger.error(e)
          @@executor.detach_and_kill
        end
      end
    end
  end

  def eval_and_execute
    @@executor.detach_and_kill
    @@config_manager.eval_rb_file(@@option_args.config_path, @@option_args.extern_args)
    argument_string = @@executor.create_all_argument_strings(@@config_manager.variable_with_value_hash, @@config_manager.variable_hash)
    @@executor.execute(argument_string)
  end

  def cmd_check
    message = if Util.windows?
                '"WMIC" command not found!' unless Util.commands_exist?('WMIC')
              else
                '"ps" and/or "pgrep" command not found!' unless Util.commands_exist?('ps', 'pgrep')
              end

    raise(StandardError, message.newline { 'Please make sure that your system supports the command.' }) if message.string?
  end

  module_function :eval_and_execute, :cmd_check, :live_reload
end
