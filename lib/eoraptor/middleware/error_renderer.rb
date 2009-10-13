require 'haml'

module Eoraptor
  module Middleware
    class ErrorRenderer
      
      @@error_mapping = {}
      @@cached_errors = {}
    
      class << self
        
        def template_path_for(code)
          Eoraptor.root.join("apps", "errors", "views", "#{code}.haml")
        end

        def response_for(code, template_path = template_path_for(code))
          @@cached_errors[code] ||= begin
            rendered = ::Haml::Engine.new(File.read(template_path)).render
            size = Rack::Utils.bytesize(rendered)
            [200, {"Content-Type" => "text/html", "Content-Length" => size.to_s}, [rendered]]
          end
        end
        
        def add_error(code, desc)
          @@error_mapping[code] = desc
        end
        
      end
      
      add_error 403, "Forbidden"
      add_error 404, "Page Not Found"
      add_error 406, "Not Acceptible"
      add_error 422, "Unprocessable Entity"
      add_error 500, "Application Error"
      
      def initialize(app, &blk)
        @app = app
        @show_error_proc = blk || proc do |request|
          Eoraptor.env == "production" || !["127.0.0.1"].include?(request.ip)
        end
      end
      
      def call(env)
        status, headers, body = @app.call(env)
        if @@error_mapping.has_key?(status) && File.exist?(self.class.template_path_for(status))
          request = env['rack.request'] || Rack::Request.new(env)
          return self.class.response_for(status) if @show_error_proc.call(request)
        end
        return [status, headers, body]
      end
      
    end
  end
end