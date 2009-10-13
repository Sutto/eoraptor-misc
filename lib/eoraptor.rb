require 'yaml'
require 'pathname'
require 'rack'

lib_dir = Pathname(__FILE__).dirname.expand_path
$:.unshift(lib_dir) unless $:.include?(lib_dir)

module Eoraptor
  require 'eoraptor/hooks'
  
  class << self
    
    attr_writer :env, :root
    
    define_hooks :before_setup, :after_setup, :during_setup
    
    def root
      @root ||= Pathname(__FILE__).dirname.dirname.expand_path
    end
    
    def env
      @env ||= (ENV['RACK_ENV'] || "development")
    end
    
    def setup
      Eoraptor::Hooks.invoke!(self, :before_setup)
      Eoraptor::Hooks.invoke!(self, :during_setup)
      Eoraptor::Hooks.invoke!(self, :after_setup)
    end
    
    require 'eoraptor/settings'
    require 'eoraptor/plugins'
    require 'eoraptor/rack'
    
    require 'eoraptor/skeleton_app'
    
  end
end