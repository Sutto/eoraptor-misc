module Eoraptor
  class << self
    
    def use(klass, *args, &blk)
      middleware << lambda { |c| klass.new(c, *args, &blk) }
    end
    
    def map(path, app = nil, &blk)
      hash = apps.detect { |a| a.is_a?(Hash) }
      if hash.nil?
        hash = {}
        apps << hash
      end
      hash[path] = app.nil? ? Rack::Builder.new(&blk) : app
    end
    
    def to_app
      normalized_apps = apps.map do |app|
        app.is_a?(Hash) ? Rack::URLMap.new(app) : app
      end
      cascade = Rack::Cascade.new(normalized_apps)
      middleware.reverse.inject(cascade) { |a, e| e.call(a) }
    end
    
    def call(env)
      (@app ||= to_app).call(env)
    end
    
    def middleware
      @middleware ||= []
    end
    
    def apps
      @apps ||= []
    end
    
  end
end