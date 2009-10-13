module Eoraptor
  class ExceptionCatcher
    
    DEFAULT_NOTIFICATION_PROC = proc { |env, exception| }
    EMPTY_RESPONSE = [500, {"Content-Type" => "text/html", "Content-Length" => "0"}, []].freeze
    
    def initialize(app, opts = {}, &blk)
      @app = app
      @exception_notifier = (blk || opts[:notify_via] || DEFAULT_NOTIFICATION_PROC)
    end
    
    def call(env)
      dup._call(env)
    end
    
    def _call(env)
      @app.call(env)
    rescue Exception => e
      @exception_notifier.call(env, e) if Eoraptor.env == "production"
      if Eoraptor.env == "development"
        error_response(env, e)
      else
        EMPTY_RESPONSE
      end
    end
    
    protected
    
    def show_exceptions
      @show_exceptions ||= Rack::ShowExceptions.new(@app)
    end
    
    # TODO: We should render a proper exception
    # / customised version here. But rack's is so nice...
    def error_response(environment, exception)
      backtrace = show_exceptions.send(:pretty, environment, exception)
      [500, {
        "Content-Type"   => "text/html",
        "Content-Length" => backtrace.join.size.to_s
      }, backtrace]
    end
    
  end
end