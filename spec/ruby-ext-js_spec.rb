require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ExtJs" do
  describe "Postgres" do
    it "sorts on id when you ask it to sort on created_at" do
      ExtJs::Postgres.pagination_opts({
        :sort => "created_at",
        :order => "desc"
      })[:order].should == [:id.asc]
    end
    
    it "specs the rest of the class or it gets the hose" do
      pending "The current spec suite is currently rigidly tied to private models. Someday we'll write a generic spec suite here."
    end
  end
  
  describe "Mongo" do
    it "specs the rest of the class or it gets the hose" do
      pending "The current spec suite is currently rigidly tied to private models. Someday we'll write a generic spec suite here."
    end
  end
end
