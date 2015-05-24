require 'sassconf/version'
require 'sassconf/config_reader'
require 'sassconf/sass_executor'
require 'optparse'
require 'ostruct'

module Sassconf
  extend Logging

  class Parser

    module HelpText
      USAGE = 'Usage: sassconf [options] [INPUT] [OUTPUT]'.paragraph
      DESCRIPTION = 'Description:'
                        .newline.blank(3) { 'Adds configuration file to Sass preprocessor.' }
                        .newline.blank(3) { "Version #{Sassconf::VERSION}" }
                        .paragraph
      REQUIRED = 'Required:'
      OPTIONAL = 'Optional:'.newline(1, :left)
    end


    def self.parse(options)

      option_args = OpenStruct.new
      option_args.config_path = String.empty
      option_args.extern_args = String.empty

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
      option_args = Parser.parse(ARGV)
      config_reader = ConfigReader.new
      executor = SassExecutor.new(ARGV[0], ARGV[1])

      config_reader.eval_rb_file(option_args.config_path, option_args.extern_args)
      argument_string = executor.create_all_argument_strings(config_reader.variable_with_value_hash, config_reader.variable_hash)
      executor.execute(argument_string)

    rescue OptionParser::MissingArgument, OptionParser::InvalidOption, SyntaxError, ArgumentError => e
      puts e.message
      logger.error(e)
    ensure
      exit
    end
  end
end
