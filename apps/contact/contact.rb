module Eoraptor
  class ContactApp < Eoraptor::SinatraApp
    
    get '/contact' do
      "Root: #{options.root}<br/>Views: #{options.views}"
    end
    
    post '/contact' do
    end
    
  end
end