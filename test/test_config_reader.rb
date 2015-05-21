require 'minitest/autorun'
require 'sassconf/config_reader'

class TestConfigReader < Minitest::Test
  CONFIG_PATH = File.dirname(__FILE__) + '/resources/Config.rb'

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @config_reader = Sassconf::ConfigReader.new
  end

  def test_positive_eval_rb_file
    assert_equal(nil, @config_reader.variable_hash)
    assert_equal(nil, @config_reader.variable_with_value_hash)

    @config_reader.eval_rb_file(CONFIG_PATH)

    assert_equal({'style' => 'compressed', 'sourcemap' => 'none'}, @config_reader.variable_with_value_hash)
    assert_equal({'no-cache' => :no_value}, @config_reader.variable_hash)

    @config_reader.eval_rb_file(CONFIG_PATH, 'dummy, inline ')

    assert_equal({'style' => 'compressed', 'sourcemap' => 'inline'}, @config_reader.variable_with_value_hash)
    assert_equal({'no-cache' => :no_value}, @config_reader.variable_hash)
  end

  def test_negative_eval_rb_file
    exception = assert_raises(ArgumentError) { @config_reader.eval_rb_file('test/resources/Config_not_exist.rb') }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_reader.eval_rb_file(String.empty) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_reader.eval_rb_file(nil) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_reader.eval_rb_file(0) }
    assert_equal("\"rb\" file path is no string, nil, empty or doesn't exist.", exception.message)

    exception = assert_raises(ArgumentError) { @config_reader.eval_rb_file(CONFIG_PATH, 0) }
    assert_equal('Extern string array is no string or nil.', exception.message)

    exception = assert_raises(ArgumentError) { @config_reader.eval_rb_file(CONFIG_PATH, nil) }
    assert_equal('Extern string array is no string or nil.', exception.message)

    assert_equal(nil, @config_reader.variable_with_value_hash)
    assert_equal(nil, @config_reader.variable_hash)
  end
end