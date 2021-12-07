require 'mkmf'

dir_config('slang')
dir_config('newt')

have_library('slang', 'SLsmg_refresh')
have_library('newt', 'newtInit')

append_cflags(ENV['CFLAGS'])
append_ldflags(ENV['LDFLAGS'])
create_makefile('ruby_newt/ruby_newt')
