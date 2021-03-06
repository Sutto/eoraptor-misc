module Eoraptor
  class SkeletonApp
    
    class CookieJar
      
      def initialize(req, res)
        @store = req.cookies
        @res = res
        @store.each_pair { |k, v| self[k] = v }
      end
      
      def [](key)
        @store[key.to_s]
      end
      
      def []=(key, value)
        key = key.to_s
        value = {:value => value} unless value.is_a?(Hash)
        @store[key] = value[:value]
        @res.set_cookie(key, value)
      end
      
      def delete(key, value = {})
        @store.delete(key.to_s)
        @res.delete_cookie(key, value)
      end
      
    end
    
    class << self
      
      def path_regexp
        @path_regexp ||= /^\/(.*)/
      end
      
      def matches_url(regexp)
        regexp = /^(#{Regexp.escape(regexp)})/ if regexp.is_a?(String)
        @path_regexp = regexp
      end
      
    end
    
    def call(env)
      dup._call(env)
    end
    
    def _call(env)
      request = Rack::Request.new(env)
      if request.path_info !~ self.class.path_regexp
        [404, {"Content-Type" => "text/html", "Content-Length" => "0"}, []]
      else
        dispatch_request(request)
      end
    end
    
    def dispatch_request(request)
      @request  = request
      @response = Rack::Response.new
      @path     = request.path_info
      method = request.request_method.downcase
      if respond_to?(method.to_sym)
        results = send(method)
        render(results) if results.is_a?(String)
      end
      @response.finish
    end
    
    attr_reader :request, :response, :path
    
    def render(text)
      @response.write(text)
    end
    
    def session
      @request.env["rack.session"] ||= {}
    end
    
    def cookies
      @cookies ||= CookieJar.new(@request, @response)
    end
    
    def params
      @params ||= @request.params
    end
    
    def redirect(path)
      @response.redirect(path)
      ""
    end
    
    def u(url, opts = {})
      path = File.join(request.script_name, url)
      query_string = []
      opts.each_pair { |k, v| query_string << "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }
      path << "?#{query_string.join("&")}" if !query_string.empty?
      return path
    end
    
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    # Blank NOP's for the actual implementation
    def get
    end
    
    def post
    end
    
    def put
    end
    
    def delete
    end
    
    def head
    end
    
  end
end