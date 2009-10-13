Eoraptor::Plugin(:sessions) do
  
  def use?
    Eoraptor['session_secret']
  end
  
  def setup
    Eoraptor.use Rack::Session::Cookie, :secret => Eoraptor['session_secret']
  end
  
end