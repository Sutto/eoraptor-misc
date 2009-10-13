class FileUploads < Eoraptor::SkeletonApp
  
  matches_url "/uploads"
  
  def get
    session[:from_uploads] = Time.now.to_i
    "Session Info: #{h session.inspect} (#{session.class})"
  end
  
end