Eoraptor::Plugin(:errors) do
  
  def use?
    true
  end
  
  def setup
    require 'eoraptor/middleware/error_renderer'
    Eoraptor.use Eoraptor::Middleware::ErrorRenderer
  end
  
end