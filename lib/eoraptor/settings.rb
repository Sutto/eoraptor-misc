module Eoraptor
  
  module Settings
    
    def [](path)
      return nil if @settings.nil?
      parts = path.to_s.split(".")
      parts.inject(@settings) do |current, key|
        current.is_a?(Hash) ? current[key] : current
      end
    end
    
    def settings
      @settings ||= {}
    end
    
    def self.setup!
      settings_file = Eoraptor.root.join("config", "settings.yml")
      if File.exist?(settings_file)
        contents = YAML.load_file(settings_file)
        @settings = (contents['default']||{}).merge(contents[Eoraptor.env]||{})
      else
        @settings = {}
      end
    end
    
  end
  
  extend Settings
  Eoraptor.during_setup { Eoraptor::Settings.setup! }
  
end