require 'rubygems'
require 'fake_web'

$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'reverse_geocode'
