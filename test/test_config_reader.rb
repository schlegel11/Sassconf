require 'minitest/autorun'
require 'sassconf/config_manager'

class TestConfigReader < Minitest::Test
  CONFIG_PATH = File.dirname(__FILE__) + '/resources/Config.rb'
  ERROR_CONFIG_PATH = File.dirname(__FILE__) + '/resources/Error_Config.rb'

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @config_manager = Sassconf::ConfigManager.new
  end

  def test_positive_eval_rb_file
    assert_equal(nil, @config_manager.variable_hash)
    assert_equal(nil, @config_manager.variable_with_value_hash)

    @config_manager.eval_rb_file(CONFIG_PATH)

    assert_equal({'style' => 'compressed', 'sourcemap' => 'none'}, @config_manager.variable_with_value_hash)
    assert_equal({'no-cache' => :no_value}, @config_manager.variable_hash)

    @config_manager.eval_rb_file(CONFIG_PATH, 'dummy, inline ')

    assert_equal({'style' => 'compressed', 'sourcemap' => 'inline'}, @config_manager.variable_with_value_hash)
    assert_equal({'no-cache' => :no_value}, @config_manager.variable_hash)
  end

  def test_negative_eval_rb_file
    exception = assert_raises(ArgumentError) { @config_manager.eval_rb_file('test/resources/Config_not_exist.rb') }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_manager.eval_rb_file(String.empty) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_manager.eval_rb_file(nil) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_manager.eval_rb_file(0) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_manager.eval_rb_file(CONFIG_PATH, 0) }
    assert_equal('Extern string array is no string.', exception.message)

    exception = assert_raises(ArgumentError) { @config_manager.eval_rb_file(CONFIG_PATH, nil) }
    assert_equal('Extern string array is no string.', exception.message)

    assert_equal(nil, @config_manager.variable_with_value_hash)
    assert_equal(nil, @config_manager.variable_hash)

    exception = assert_raises(SyntaxError) { @config_manager.eval_rb_file(ERROR_CONFIG_PATH) }
    assert_includes(exception.message, ":2: syntax error, unexpected ';'\narg_no_cache =; :no_value\n")
  end

  def test_negative_watch_update
    exception = assert_raises(ArgumentError) { @config_manager.watch_update(nil) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)
    exception = assert_raises(ArgumentError) { @config_manager.watch_update(String.empty) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)
    exception = assert_raises(ArgumentError) { @config_manager.watch_update('/no/path') }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)
  end
end