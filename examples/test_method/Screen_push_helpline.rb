#!/usr/bin/env ruby

require 'rubygems'
require 'newt'

begin
  Newt::Screen.new

  Newt::Screen.push_helpline('Hit Key!!')
  Newt::Screen.wait_for_key
ensure
  Newt::Screen.finish
end
