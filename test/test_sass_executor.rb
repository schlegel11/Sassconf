require 'minitest/autorun'
require 'sassconf/sass_executor'
require 'sassconf/config_manager'

class TestSassExecuter < Minitest::Test

  SCSS_PATH = File.dirname(__FILE__) + '/resources/Input.scss'
  CSS_PATH = File.dirname(__FILE__) + '/resources/Output.css'
  CONFIG_PATH = File.dirname(__FILE__) + '/resources/Config.rb'
  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @config_manager = Sassconf::ConfigManager.new
    @sass_executor = Sassconf::SassExecutor.new(SCSS_PATH, CSS_PATH)
  end

  def test_positive_create_argument_with_value_string
    @config_manager.eval_rb_file(CONFIG_PATH)

    assert_equal('--style=compressed --sourcemap=none', @sass_executor.create_argument_with_value_string(@config_manager.variable_with_value_hash))
  end

  def test_negative_create_argument_with_value_string
    exception = assert_raises(ArgumentError) { @sass_executor.create_argument_with_value_string(String.empty) }
    assert_equal('Argument hash is no hash or nil.', exception.message)

    exception = assert_raises(ArgumentError) { @sass_executor.create_argument_with_value_string(nil) }
    assert_equal('Argument hash is no hash or nil.', exception.message)
  end

  def test_positive_create_argument_string
    @config_manager.eval_rb_file(CONFIG_PATH)

    assert_equal('--no-cache', @sass_executor.create_argument_string(@config_manager.variable_hash))
  end

  def test_negative_create_argument_string
    exception = assert_raises(ArgumentError) { @sass_executor.create_argument_string(String.empty) }
    assert_equal('Argument hash is no hash or nil.', exception.message)

    exception = assert_raises(ArgumentError) { @sass_executor.create_argument_string(nil) }
    assert_equal('Argument hash is no hash or nil.', exception.message)
  end

  def test_positive_create_all_argument_strings
    @config_manager.eval_rb_file(CONFIG_PATH)

    assert_equal('--style=compressed --sourcemap=none --no-cache', @sass_executor.create_all_argument_strings(@config_manager.variable_with_value_hash, @config_manager.variable_hash))
  end

  def test_negative_create_all_argument_strings
    exception = assert_raises(ArgumentError) { @sass_executor.create_all_argument_strings(@config_manager.variable_with_value_hash, String.empty) }
    assert_equal('Argument hash is no hash or nil.', exception.message)

    exception = assert_raises(ArgumentError) { @sass_executor.create_all_argument_strings(@config_manager.variable_with_value_hash, nil) }
    assert_equal('Argument hash is no hash or nil.', exception.message)

    exception = assert_raises(ArgumentError) { @sass_executor.create_all_argument_strings(String.empty, @config_manager.variable_hash) }
    assert_equal('Argument hash is no hash or nil.', exception.message)

    exception = assert_raises(ArgumentError) { @sass_executor.create_all_argument_strings(nil, @config_manager.variable_hash) }
    assert_equal('Argument hash is no hash or nil.', exception.message)
  end

  def test_positive_execute
    @config_manager.eval_rb_file(CONFIG_PATH)
    @sass_executor.execute(@sass_executor.create_all_argument_strings(@config_manager.variable_with_value_hash, @config_manager.variable_hash))
    @sass_executor.wait

    assert_equal(".navigation{border-color:#3BBFCE;color:#2ca2af}\n", File.read(CSS_PATH))

    File.delete(CSS_PATH)
  end

  def test_negative_execute
    @config_manager.eval_rb_file(CONFIG_PATH)

    exception = assert_raises(ArgumentError) { @sass_executor.execute(0) }
    assert_equal('Argument string is no string, nil or empty.', exception.message)

    exception = assert_raises(ArgumentError) { @sass_executor.execute(String.empty) }
    assert_equal('Argument string is no string, nil or empty.', exception.message)

    exception = assert_raises(ArgumentError) { @sass_executor.execute(nil) }
    assert_equal('Argument string is no string, nil or empty.', exception.message)
  end
end