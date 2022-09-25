require 'mkmf'

pkg_config('slang')
pkg_config('libnewt')

append_cflags(ENV['CFLAGS'])
append_ldflags(ENV['LDFLAGS'])

create_makefile('ruby_newt/ruby_newt')
