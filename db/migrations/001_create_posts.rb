class CreatePosts < Sequel::Migration
  
  def up
    create_table :posts do
      primary_key :id, :type => Integer
      String      :title
      String      :format
      text        :summary
      text        :contents
      Time        :posted_at
      TrueClass   :published
    end
  end
  
  def down
    drop_table :posts
  end
  
end