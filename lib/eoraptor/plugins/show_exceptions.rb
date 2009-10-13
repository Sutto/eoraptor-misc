Eoraptor::Plugin(:show_exceptions) do
  
  def use?
    true
  end
  
  def setup
    case Eoraptor.env
    when "development"
      Eoraptor.use Rack::ShowExceptions
    when "production"
    when "test"
    end
  end
  
end