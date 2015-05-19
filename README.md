# Sassconf

With the Sassconf command tool you can use a config file for defining your [Sass](https://github.com/sass/sass) options.
If you liked the config file in any Compass environment then you'll like that one also because it's very similar :)

## Requirements

- [Sass](https://github.com/sass/sass)

## Installation

Install it directly from [RubyGems](https://rubygems.org):

  ```bash
  gem install sassconf
  ```

## Usage

General usage:

  ```bash
  sassconf [options] [INPUT] [OUTPUT]
  ```

You can type:

  ```bash
  sassconf -h
  ```
    
or only:
    
  ```bash
  sassconf
  ```

in your console for show the help text.

###Config File
For using options from Sass you have to use special variable prefixes "arg_NAME" and "varg_NAME".

 - "arg_NAME" for any [Sass](http://sass-lang.com/documentation/file.SASS_REFERENCE.html) options without a "=" sign like:
 
  ```bash
  --style
  --load-path
  --no-cache
  ...
  ```
 - "varg_NAME" for any [Sass](http://sass-lang.com/documentation/file.SASS_REFERENCE.html) options with a "=" sign like:
 
  ```bash
  --sourcemap
  ```
 
   If there is an option with a "-" sign, you have to replace it with a "_" sign in your variable like:
   
   ```bash
   "no-cache" changes to "arg_no_cache"
    ```
    
    If there is an option without a value, you have to define it with the symbol ":no_value" like:
    
    ```ruby
    arg_no_cache = :no_value
    ```
      
   Example config:
   
   ```ruby
   arg_style = 'compressed'
   arg_load_path = '/your/path'
   arg_no_cache = :no_value
   varg_sourcemap = 'none'
   arg_precision = 10
   ```

You can also set a list of values on the command line which you can use in your config file:

  ```bash
  sassconf --config /path/config.rb --args value1,value2,value3
  ```
   
   In your config file you have to use the array "extern_args" like:
   
   ```ruby
   extern_args[0] #For "value1"
   extern_args[1] #For "value2"
   extern_args[2] #For "value3"
   arg_style = 'compressed'
   ...
   ```

##CommandLine Options

###Required Options
 - -c, --config CONFIG_FILE
   - Specify a ruby config file e.g.: /PATH/config.rb

###Optional Options
 - -a, --args ARGS
   - Comma separated list of values e.g.: val_a, val_b,...
  
 - v, --verbose
   - Print all log messages.
  
 - -?, -h, --help
   - Show help text.

##Examples
###Sample 1 - Input Output File

 **config.rb**
  ```ruby
  production = false
  arg_no_cache = :no_value
  varg_style = production ? 'compressed' : 'expanded'
  test_no_arg = 'no_arg'
  varg_sourcemap = 'none'
  ```
  
  **input.scss**
  ```sass
  $color: #3BBECE;

  .navigation {
  border-color: $color;
  color: darken($color, 9%);
  }
  ```
  
  **In console type:**
  
  ```bash
  sassconf -c ./config.rb ./input.scss ./output.css
  ```
  
  **Result:**
  
  **output.css**
  ```css
  .navigation {
  border-color: #3BBFCE;
  color: #2ca2af;
  }
  ```

###Sample 2 - Use a "Filewatcher"

 **config.rb**
  ```ruby
  production = false
  arg_no_cache = :no_value
  varg_style = production ? 'compressed' : 'expanded'
  test_no_arg = 'no_arg'
  varg_sourcemap = 'none'
  arg_watch = "./:./out"
  ```
  
  **input.scss**
  ```sass
  $color: #3BBECE;

  .navigation {
  border-color: $color;
  color: darken($color, 9%);
  }
  ```
  
  **In console type:**
  
  ```bash
  sassconf -c ./config.rb
  ```
  
  **Console Output:**
  ```bash
  >>> Sass is watching for changes. Press Ctrl-C to stop.
  directory ./out
      write ./out/input.css
  ```
  
  **Result:**
  
  **/out/input.css**
  ```css
  .navigation {
  border-color: #3BBFCE;
  color: #2ca2af;
  }
  ```
