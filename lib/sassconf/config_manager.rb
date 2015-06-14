require_relative 'util'
require_relative 'logger'
require_relative 'core_extensions'

module Sassconf
  class ConfigManager
    include Logging

    VARIABLE_PREFIX = 'arg_'
    VARIABLE_WITH_VALUE_PREFIX = 'varg_'
    ARRAY_FROM_STRING_SEPARATOR = ','

    def eval_rb_file(file_path, extern_string_array = String.empty)
      Util.pre_check((file_path.string? and file_path.not_nil_or_empty? and File.exist?(file_path)), "\"rb\" file path is no string, nil, empty or doesn't exist.")
      Util.pre_check(extern_string_array.string?, 'Extern string array is no string.')

      @bind_extern_string_array = extern_string_array
      inject_array = 'extern_args = create_array_from_string(@bind_extern_string_array);'
      source_file = File.read(file_path)
      collect_variables = '@vh = create_variable_hash(local_variables, binding); @vwvh = create_variable_with_value_hash(local_variables, binding)'
      logger.info("Eval config file: #{file_path}")
      eval_line = __LINE__ + 1
      eval("#{inject_array} \n #{source_file} \n #{collect_variables}", reader_binding, file_path, __LINE__ - eval_line)
    end

    def watch_update(file_path)
      Util.pre_check((file_path.string? and file_path.not_nil_or_empty? and File.exist?(file_path)), "\"rb\" file path is no string, nil, empty or doesn't exist.")
      Util.pre_check(block_given?, 'No block is given.')
      FileWatcher.new([file_path]).watch do |filename, event|
        if (event == :changed)
          yield(filename)
        end
      end
    end

    def variable_hash
      @vh
    end

    def variable_with_value_hash
      @vwvh
    end

    private
    def create_variable_hash(variables, binding)
      create_hash(VARIABLE_PREFIX, variables, binding)
    end

    def create_variable_with_value_hash(variables, binding)
      create_hash(VARIABLE_WITH_VALUE_PREFIX, variables, binding)
    end

    def create_hash(prefix, variables, binding)
      logger.info("Create Sass argument hash from config variables: #{variables}")
      variables.reduce({}) { |hash, var| var_string = var.to_s; var_string.start_with?(prefix) ? hash.merge(var_string.sub(prefix, String.empty).gsub('_', '-') => eval(var_string, binding)) : hash }
    end

    def create_array_from_string(arg)
      logger.info("Create \"extern_args\" array from string: #{arg}")
      arg.split(ARRAY_FROM_STRING_SEPARATOR).collect { |elem| elem.strip }
    end

    def reader_binding
      binding
    end
  end
end