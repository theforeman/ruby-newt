require 'mkmf'

pkg_config('s-lang')
pkg_config(RUBY_PLATFORM.include?('darwin') ? 'libnewt' : 'newt')

append_cflags(ENV['CFLAGS'])
append_ldflags(ENV['LDFLAGS'])

create_makefile('ruby_newt/ruby_newt')
