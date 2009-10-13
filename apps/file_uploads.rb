class FileUploads < Eoraptor::SkeletonApp
  
  matches_url "/uploads"
  
  def get
    "Hello there"
  end
  
end