module Eoraptor
  class ContactApp < Eoraptor::SinatraApp
    
    mapping_via '/contact'
    
    get '/' do
      haml :index
    end
    
    post '/' do
      redirect u('/', :sent => true)
    end
    
  end
end