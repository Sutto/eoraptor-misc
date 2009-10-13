Eoraptor::Plugin(:exceptions) do
  
  def use?
    true
  end
  
  def setup
    require 'eoraptor/middleware/exception_catcher'
    Eoraptor.use Eoraptor::ExceptionCatcher
  end
  
end