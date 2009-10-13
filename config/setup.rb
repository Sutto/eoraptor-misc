require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname.dirname.join("lib", "eoraptor")

Eoraptor.setup

# Initialize any other apps here
Eoraptor.app FileUploads.new