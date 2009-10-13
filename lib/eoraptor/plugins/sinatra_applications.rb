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
          if application.is_a?(SinatraApp)
            Eoraptor.app(application.new)
          elsif application.is_a?(Array)
            Eoraptor.map(application.first, application.last)
          end
        end
      end
    end

  end
  
  class SinatraApp < ::Sinatra::Base
    
    set :views,  Eoraptor.root.join("views").to_s
    set :public, Eoraptor.root.join("public").to_s
    
    def self.inherited(klass)
      SinatraApps.apps << klass
      super
    end
    
    def session
      env['rack.session'] || {}
    end
    
    def h(text)
      Rack::Utils.escape_html(text)
    end
    
    def u(url, opts = {})
      path = "#{env["SCRIPT_NAME"]}/#{url}"
      query_string = []
      opts.each_pair { |k, v| query_string << "#{URI.escape(k)}=#{URI.escape(v)}" }
      path << "?#{query_string.join("&")}" if !query_string.empty?
      return path
    end
    
    def self.mapping_via(sub_path)
      SinatraApps.apps.delete(self)
      klass = self
      SinatraApps.apps << [sub_path, klass]
    end
    
  end
  
  class StylesheetApp < SinatraApp
    
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