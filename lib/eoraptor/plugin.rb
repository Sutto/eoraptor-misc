module Eoraptor
  class Plugin
    
    def self.register_as(name)
      Eoraptor.plugins[name] = self.new
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
  
end