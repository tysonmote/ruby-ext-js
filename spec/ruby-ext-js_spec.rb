require "date"
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ExtJs" do
  # describe "Postgres" do
  #   it "sorts on id when you ask it to sort on created_at" do
  #     ExtJs::Postgres.pagination_opts({
  #       :sort => "created_at",
  #       :order => "desc"
  #     })[:order].should == [:id.asc]
  #   end
  #   
  #   it "specs the rest of the class or it gets the hose" do
  #     pending "The current spec suite is currently rigidly tied to private models. Someday we'll write a generic spec suite here."
  #   end
  # end
  
  describe "Mongo" do
    describe "conditions" do
      class TestMongoNoFilters < ExtJs::Mongo; end
      
      class TestMongoWithFilters < ExtJs::Mongo
        def self.allowed_filters
          ["state", "score", "inserted_at"]
        end
      end
      
      it "handles empty params" do
        mongo = TestMongoNoFilters.new( {} )
        mongo.conditions.should == {}
        
        mongo = TestMongoWithFilters.new( {} )
        mongo.conditions.should == {}
      end
      
      it "handles filter params" do
        params = {
          "filter" => {
            "0" => {
              "field" => "state",
              "data" => {
                "value" => "open"
              }
            }
          }
        }
        mongo = TestMongoNoFilters.new( params )
        mongo.conditions.should == {}
        
        mongo = TestMongoWithFilters.new( params )
        mongo.conditions.should == { "state" => "open" }
      end
      
      it "handles complex filter params" do
        params = {
          "filter" => {
            "0" => {
              "field" => "state",
              "data" => {
                "value" => "open"
              }
            },
            "1" => {
              "field" => "score",
              "data" => {
                "value" => ["5", "4"]
              }
            },
            "2" => {
              "field" => "score"
            },
            "3" => {
              "data" => {
                "value" => ["5", "4"]
              }
            },
            "4" => {
              "field" => "score",
              "data" => {
                "value" => []
              }
            }
          }
        }
        
        mongo = TestMongoWithFilters.new( params )
        mongo.conditions.should == { "state" => "open", "score" => { "$in" => ["5", "4"] } }
      end
      
      it "handles date range params" do
        offset = Time.now.utc_offset
        date = Date.parse "11/26/2010"
        start_time = Time.utc( date.year, date.month, date.day ) - offset
        end_time = Time.utc( date.year, date.month, date.day, 23, 59, 59 ) - offset
        
        params = { "filter" => {
          "0" => {
            "data" => {
              "type" => "date",
              "value" => "11/26/2010",
              "comparison" => "lt"
            },
            "field" => "inserted_at"
          }
        }}
        mongo = TestMongoWithFilters.new( params )
        mongo.conditions.should == { "inserted_at" => { "$lte" => start_time } }
        
        params = { "filter" => {
          "0" => {
            "data" => {
              "type" => "date",
              "value" => "11/26/2010",
              "comparison" => "gt"
            },
            "field" => "inserted_at"
          }
        }}
        mongo = TestMongoWithFilters.new( params )
        mongo.conditions.should == { "inserted_at" => { "$gte" => start_time } }
        
        params = { "filter" => {
          "0" => {
            "data" => {
              "type" => "date",
              "value" => "11/26/2010",
              "comparison" => "eq"
            },
            "field" => "inserted_at"
          }
        }}
        mongo = TestMongoWithFilters.new( params )
        mongo.conditions.should == { "inserted_at" => { "$gte" => start_time, "$lte" => end_time } }
      end
      
      it "handles invalid comparison operators by falling back to $in" do
        offset = Time.now.utc_offset
        date = Date.parse "11/26/2010"
        start_time = Time.utc( date.year, date.month, date.day ) - offset
        
        params = { "filter" => {
          "0" => {
            "data" => {
              "type" => "date",
              "value" => "11/26/2010",
              "comparison" => "BOO"
            },
            "field" => "inserted_at"
          }
        }}
        
        mongo = TestMongoWithFilters.new( params )
        mongo.conditions.should == { "inserted_at" => { "$in" => start_time } }
      end
    end
    
    describe "opts" do
      class TestMongo < ExtJs::Mongo; end
      
      it "handles empty params with sensible defaults" do
        TestMongo.new( {} ).options.should == { :limit => 50, :skip => 0 }
      end
      
      it "handles pagination" do
        TestMongo.new( "start" => "50", "limit" => "10" ).options.should == { :limit => 10, :skip => 50 }
        TestMongo.new( "start" => "10" ).options.should == { :limit => 50, :skip => 0 }
        TestMongo.new( "limit" => "10" ).options.should == { :limit => 10, :skip => 0 }
      end
      
      it "handles sorting" do
        TestMongo.new( "sort" => "foo" ).options.should == { :limit => 50, :skip => 0, :sort => [:foo, :asc] }
        TestMongo.new( "sort" => "foo", "dir" => "desc" ).options.should == { :limit => 50, :skip => 0, :sort => [:foo, :desc] }
        TestMongo.new( "sort" => "foo", "dir" => "no idea" ).options.should == { :limit => 50, :skip => 0, :sort => [:foo, :asc] }
        TestMongo.new( "dir" => "asc" ).options.should == { :limit => 50, :skip => 0 }
      end
      
      it "prevents dumb queries" do
        TestMongo.new( "start" => "9999999", "limit" => "9999999" ).options.should == { :limit => 500, :skip => 9999999 }
        TestMongo.new( "start" => "-200", "limit" => "-200" ).options.should == { :limit => 50, :skip => 0 }
      end
    end
  end
end
