require 'sinatra'
require 'haml'
require 'sass'

module Eoraptor
  
  class SinatraApps < Plugin
    
    register_as :sinatra

    def self.apps
      @apps ||= []
    end

    def use?
      true
    end

    def setup
      Eoraptor.after_setup do
        SinatraApps.apps.each do |application|
          if application.is_a?(Array)
            Eoraptor.map(application.first, application.last)
          else
            Eoraptor.app(application.new)
          end
        end
      end
    end

  end
  
  class SinatraApp < ::Sinatra::Base
    
    set(:root, Proc.new do
      app_name = self.eoraptor_app_name || "default"
      Eoraptor.root.join("apps", app_name).to_s
    end)
    set :views,  Proc.new { File.join(root, "views") }
    set :public, Eoraptor.root.join("public").to_s
    
    class << self
      
      attr_accessor :eoraptor_app_name
      
      def inherited(klass)
        klass.eoraptor_app_name = Eoraptor.current_app_name
        SinatraApps.apps << klass
        super
      end
      
      def mapping_via(sub_path)
        SinatraApps.apps.delete(self)
        klass = self
        SinatraApps.apps << [sub_path, klass]
      end
      
    end
    
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def u(url, opts = {})
      path = File.join(request.script_name, url)
      query_string = []
      opts.each_pair { |k, v| query_string << "#{URI.escape(k.to_s)}=#{URI.escape(v.to_s)}" }
      path << "?#{query_string.join("&")}" if !query_string.empty?
      return path
    end
    
  end
  
  class StylesheetApp < SinatraApp
    
    def self.current_app_name; ""; end
    
    mapping_via '/stylesheets'
    
    set :stylesheet_dir, Eoraptor.root.join("stylesheets").to_s
    
    get '/*.css' do
      stylesheet_name = params[:splat].first
      stylesheet = render_stylesheet(stylesheet_name)
      if !stylesheet.nil?
        content_type 'text/css', :charset => 'utf-8'
        stylesheet
      else
        halt 404
      end
    end
    
    def render_stylesheet(name)
      name = name.split("/").reject { |p| p.include?(".") }.join("/")
      stylesheet_path = File.join(options.stylesheet_dir, name) + ".sass"
      if File.readable?(stylesheet_path)
        ::Sass::Engine.new(File.read(stylesheet_path)).render
      else
        nil
      end
    end
    
  end
  
end