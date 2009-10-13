module Eoraptor
  
  module PluginLoader
    
    DEFAULT_LOAD_ORDER = [:errors, :show_exceptions, :rack_bug, :models, :sinatra]
    
    def plugins
      @@plugins ||= {}
    end
    
    def load_order
      @@load_order ||= DEFAULT_LOAD_ORDER
    end
    
    def install_plugins
      self.load_order.each do |plugin_name|
        plugin = plugins[plugin_name]
        next if plugin.nil? || !plugin.use?
        plugin.setup
      end
    end
    
    def load_all
      load_from_dir Eoraptor.root.join("lib", "eoraptor", "plugins")
      load_from_dir Eoraptor.root.join("plugins")
    end
    
    def setup!
      load_all
      install_plugins
    end
    
    protected
    
    def load_from_dir(dir)
      Dir[dir.join("**", "*.rb")].each { |r| require f }
    end
    
    extend self
    
  end
  
  class Plugin
    
    def self.register_as(name)
      Eoraptor::PluginLoader.plugins[name] = self.new
    end
    
    def use?
      # NOP
    end
    
    def setup
      # NOP
    end
    
  end
  
  def self.Plugin(name, &blk)
    klass = Class.new(Plugin, &blk)
    klass.register_as(name)
    klass
  end
  
  Eoraptor.during_setup { Eoraptor::PluginLoader.setup! }
  
end