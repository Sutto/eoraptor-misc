require 'yaml'
require 'pathname'
require 'rack'

lib_dir = Pathname(__FILE__).dirname.expand_path
$:.unshift(lib_dir) unless $:.include?(lib_dir)

module Eoraptor
  require 'eoraptor/hooks'
  
  # Applications should ALWAYS be last. It defines the actual application
  DEFAULT_PLUGIN_ORDER = [:errors, :show_exceptions, :rack_bug, :models, :sinatra_applications]
  
  class << self
    
    attr_writer :env, :root, :plugins, :plugin_order
    
    define_hooks :before_setup, :after_setup
    
    def plugins
      @plugins ||= {}
    end
    
    def plugin_order
      @plugin_order ||= DEFAULT_PLUGIN_ORDER
    end
    
    def root
      @root ||= Pathname(__FILE__).dirname.dirname.expand_path
    end
    
    def env
      @env ||= (ENV['RACK_ENV'] || "development")
    end
    
    def [](path)
      return nil if @settings.nil?
      parts = path.to_s.split(".")
      parts.inject(@settings) do |current, key|
        current.is_a?(Hash) ? current[key] : current
      end
    end
    
    def setup
      Eoraptor::Hooks.invoke!(self, :before_setup)
      load_settings
      load_plugins
      Eoraptor::Hooks.invoke!(self, :after_setup)
    end
    
    def load_settings
      settings_file = root.join("config", "settings.yml")
      if File.exist?(settings_file)
        contents = YAML.load_file(settings_file)
        @settings = (contents['default']||{}).merge(contents[env]||{})
      else
        @settings = {}
      end
    end
    
    def load_plugins
      Dir[root.join("plugins", "**", "*.rb")].each do |file|
        require file
      end
      self.plugin_order.each do |plugin_name|
        plugin = self.plugins[plugin_name]
        next if plugin.nil? || !plugin.use?
        plugin.setup
      end
    end
    
  end
  
  # Load default libraries
  require 'eoraptor/rack_app_support'
  require 'eoraptor/plugin'
  require 'eoraptor/models'
  require 'eoraptor/show_exceptions'
  require 'eoraptor/rack_bug'
  require 'eoraptor/sinatra_applications'
  require 'eoraptor/error_renderer_plugin'
  
end