require_relative 'core_extensions'

module Sassconf
  module MsDos
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def process_childs(ppid, &block)
        Util.pre_check((ppid.integer? and ppid > 0), 'Ppid is no integer.')
        CrossSystem.process_childs("wmic process where (ParentProcessId=#{ppid.to_s}) get ProcessId", &block)
      end

      def process_exists?(pid)
        Util.pre_check((pid.integer? and pid > 0), 'Pid is no integer.')
        CrossSystem.process_exists?("wmic process where (ProcessId=#{pid.to_s}) get ProcessId")
      end
    end
  end

  module Unix
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def process_childs(ppid, &block)
        Util.pre_check((ppid.integer? and ppid > 0), 'Ppid is no integer.')
        CrossSystem.process_childs('pgrep', '-P', ppid.to_s, &block)
      end

      def process_exists?(pid)
        Util.pre_check((pid.integer? and pid > 0), 'Pid is no integer.')
        CrossSystem.process_exists?('ps', '-o', 'pid=', pid.to_s)
      end
    end
  end

  module CrossSystem
    module_function

    def process_childs(*cmds)
      Util.pre_check((cmds.any? and cmds.all? { |elem| elem.string? }), 'cmds is empty or element is no string.')

      out, status = Open3.capture2(*cmds)
      out.each_line do |elem|
        pid = elem.to_i;
        unless pid == 0 && block_given?
          yield(pid)
        end
      end
    end

    def process_exists?(*cmds)
      Util.pre_check((cmds.any? and cmds.all? { |elem| elem.string? }), 'cmds is empty or element is no string.')

      out, status = Open3.capture2(*cmds)
      out.each_line.select { |elem| elem.to_i != 0 }.any?
    end
  end

  class Util
    def self.init
      windows? ? include(Sassconf::MsDos) : include(Sassconf::Unix)
    end

    private_class_method :new, :init

    def self.pre_check(term, message = String.empty)
      raise(ArgumentError, message) unless term
    end

    def self.which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        }
      end
      nil
    end

    def self.commands_exist?(*cmds)
      cmds.all? { |cmd| which(cmd).not_nil_or_empty? }
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

    init
  end
end

