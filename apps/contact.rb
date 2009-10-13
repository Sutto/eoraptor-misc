module Eoraptor
  class ContactApp < Eoraptor::SinatraApp
    
    get '/contact' do
      session[:from_sinatra] = Time.now.to_i
      "Session Info: #{h session.inspect} (#{session.class})"
    end
    
    post '/contact' do
    end
    
  end
end