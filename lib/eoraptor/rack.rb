module Eoraptor

  module DefaultRackStack
    
    def rack_stack
      @rack_stack ||= RackStack.new
    end
    
    def use(klass, *args, &blk)
      rack_stack.use(klass, *args, &blk)
    end
    
    def app(app, *args, &blk)
      rack_stack.app(app, *args, &blk)
    end
    
    def map(route, app = nil, &blk)
      rack_stack.map(route, app, &blk)
    end
    
    def call(env)
      (@app ||= rack_stack.to_app).call(env)
    end
    
  end
  
  class RackStack
    
    def initialize(&blk)
      @apps       = {}
      @middleware = {}
      @route_map  = {}
      instance_eval(&blk) if block_given?
    end
    
    def use(klass, *args, &blk)
      @middleware << lambda { |c| klass.new(c, *args, &blk) }
    end
    
    def app(app, *args, &blk)
      if !args.empty? || block_given?
        @apps << lambda { app.new(*args, &blk) }
      else
        @apps << lambda { app }
      end
    end
    
    def map(route, app = nil, &blk)
      if app.present?
        @route_map[route] = lambda { app }
      else
        @route_map[route] = lambda { RackStack.new(&blk).to_app }
      end
    end
    
    def to_app
      resolved_apps = @apps.map { |a| a.call }
      resolved_apps << Rack::URLMap.new(resolved_route_map)
      cascade = Rack::Cascade.new(resolved_apps)
      @middleware.reverse.inject(cascade) { |a, e| e.call(a) }
    end
    
    def resolved_route_map
      resolved = {}
      @route_map.each_pair { |k, v| resolved[k] = v.call }
      resolved
    end
    
  end
  
  extend DefaultRackStack
  
  # This is run after plugins have been loaded
  during_setup do
    Dir[Eoraptor.root.join("apps", "**", "*.rb")].each do |application|
      require application
    end
  end
  
end