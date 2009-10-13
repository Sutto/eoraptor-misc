Eoraptor::Plugin(:debugging) do
  
  def use?
    Eoraptor.env == "development"
  end
  
  def setup
    require 'rack/bug'
    Eoraptor.use Rack::Bug
  rescue LoadError
  end
  
end