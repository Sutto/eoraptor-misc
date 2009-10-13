class Post < Sequel::Model
  plugin :validation_helpers
  
  def validate
    validates_presence [:title, :contents]
  end
  
end