require 'logger'

module Sassconf
  module Logging
    def logger
      @logger ||= Logging.logger_for(self.class.name)
    end

    @loggers = {}

    class << self
      @@active = false

      def activate()
        @@active = true
      end

      def logger_for(classname)
        @loggers[classname] ||= configure_logger_for(classname)
      end

      def configure_logger_for(classname)
        logger = Logger.new(@@active ? STDOUT : nil)
        logger.progname = classname
        logger.level = Logger::INFO
        logger
      end
    end
  end
end