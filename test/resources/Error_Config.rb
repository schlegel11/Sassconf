production = true
arg_no_cache =; :no_value
varg_style = production ? 'compressed' : 'no_production'
test_no_arg = 'no_arg'
varg_sourcemap = extern_args.empty? ? 'none' : extern_args[1]