Eoraptor::Plugin(:models) do
  
  def use?
    !Eoraptor['database'].to_s.empty?
  end
  
  def setup
    setup_database
    # Load all of the models
    Dir[Eoraptor.subapp_path("models", "**", "*.rb")].each do |file|
      model_folder = file.to_s.gsub(/models\/(.*)\.rb$/, 'models')
      $:.unshift(model_folder) unless $:.include?($:)
      require File.basename(file.to_s.gsub("#{model_folder}/", ""))
    end
    define_migrator
  end 
  
  protected
  
  def define_migrator
    require 'sequel/extensions/migration'
    def Eoraptor.migrate!
      Sequel::Migrator.apply(Eoraptor.database, Eoraptor.root.join("db", "migrations").to_s)
    end
  end
  
  def setup_database
    require 'sequel'
    class << Eoraptor;  attr_accessor :database; end
    Eoraptor.database = Sequel.connect(Eoraptor['database'])
  end
  
end