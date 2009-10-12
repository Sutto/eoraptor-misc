Eoraptor::Plugin(:models) do
  
  def use?
    !Eoraptor['database'].to_s.empty?
  end
  
  def setup
    
    setup_database
    model_dir = Eoraptor.root.join("models")
    $:.unshift(model_dir)
    # Load all of the models
    Dir[Eoraptor.root.join("models", "**", "*.rb")].each do |file|
      require File.basename(file.to_s.gsub("#{model_dir}/", ""))
    end
  end 
  
  protected
  
  def setup_database
    require 'sequel'
    class << Eoraptor
      attr_accessor :database
    end
    Eoraptor.database = Sequel.connect(Eoraptor['database'])
  end
  
end