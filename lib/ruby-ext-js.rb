require "date"

module ExtJs
  class Postgres
    def self.db_opts(params, opts = {}); raise NotImplementedError; end
    
    protected
    
    # Converts Ext.js' wacky params structure into a Postgres db query
    # opts hash for pagination.
    def self.pagination_opts(params, opts = {})
      opts = {
        :max_offset => 10000,
        :max_limit => 100
      }.merge opts
      
      # Pagination
      offset = offset_param( params, opts[:max_offset] )
      limit = limit_param( params, opts[:max_limit] )
      
      # Sort order
      order = order_param( params )
      
      {
        :order => [order],
        :offset => offset,
        :limit => limit
      }
    end
    
    # Given Ext.js params hash, returns a Datamapper sort param
    def self.order_param( params )
      sort = case params["sort"]
        when "created_at"
          :id
        else
          params["sort"] ? params["sort"].to_sym : :id
      end
      params["dir"] =~ /desc/i ? sort.desc : sort.asc
    end
    
    # Given Ext.js params hash, returns a Datamapper offset param
    def self.offset_param( params, max_offset )
      [( params["start"] && params["start"].to_i ) || 0, max_offset].min
    end
    
    # Given Ext.js params hash, returns a Datamapper limit param
    def self.limit_param( params, max_limit )
      [( params["limit"] && params["limit"].to_i ) || 25, max_limit].min
    end
    
    # Filtering
    
    def self.allowed_filters
      []
    end
    
    def self.get_filter_data( params )
      return unless params["filter"] && params["filter"]["0"]
      if allowed_filters.include?( params["filter"]["0"]["field"] )
        {
          :field => params["filter"]["0"]["field"],
          :values => Array( params["filter"]["0"]["data"]["value"] )
        }
      end
    end
  end
  
  class Mongo
    DEFAULT_SKIP = 0
    MAX_LIMIT = 500
    DEFAULT_LIMIT = 50
    
    def initialize( params )
      @params = {}
      params.each do |k, v|
        @params[k.to_s] = v
      end
    end
    
    # @return [Hash] `find()` conditions for `Mongo::Collection.find( conditions, opts )`
    def conditions
      self.class.search_param( @params )
    end
    
    # @return [Hash] `find()` options for `Mongo::Collection.find( conditions, opts )`
    def options
      opts = {}
      
      opts.merge! self.class.skip_param( @params )
      opts.merge! self.class.limit_param( @params )
      opts.merge! self.class.sort_param( @params )
      
      opts
    end
    
    # @return [Array] Array of string values representing keys that are filterable.
    def self.allowed_filters
      []
    end
    
    protected
    
    def self.skip_param( params )
      return { :skip => DEFAULT_SKIP } unless params.key?( "start" ) && params.key?( "limit" )
      { :skip => [params["start"].to_i, 0].max }
    end
    
    def self.limit_param( params )
      return { :limit => DEFAULT_LIMIT } unless params.key?( "limit" ) && params["limit"].to_i > 0
      { :limit => [params["limit"].to_i, MAX_LIMIT].min }
    end
    
    def self.sort_param( params )
      return {} unless params.key?( "sort" )
      
      sort = params["sort"] ? params["sort"].to_sym : :id
      dir = params["dir"] =~ /desc/i ? :desc : :asc
      
      { :sort => [sort, dir] }
    end
    
    def self.search_param( params )
      conds = {}
      
      if params["filter"] && params["filter"].size > 0
        0.upto( params["filter"].size - 1 ).each do |i|
          i = i.to_s
          
          next unless params["filter"][i]
          
          field, values = self.filter_for( params["filter"][i] )
          
          unless field.empty? || !allowed_filters.include?( field ) || values.empty?
            conds.merge! field => values
          end
        end
      end
      
      conds
    end
    
    def self.filter_for( hash )
      hash["data"] ||= {}
      hash["field"] ||= ""
      
      field = hash["field"].gsub(/[^\.\w\d_-]/, "").strip
      values = Array( hash["data"]["value"] )
      comparison = self.comparison_for( hash["data"]["comparison"] )
      
      case hash["data"]["type"]
        when "date"
          offset = Time.now.utc_offset
          values.map!{ |date| date = Date.parse( date ); Time.utc( date.year, date.month, date.day ) }
          if comparison == "=="
            start_time = values[0]
            end_time = Time.utc( start_time.year, start_time.month, start_time.day, 23, 59, 59 )
            values = { comparison_for( "gt" ) => start_time - offset, comparison_for( "lt" ) => end_time - offset }
          else
            values = { comparison => values[0] - offset }
          end
        else
          if values.size == 1
            values = values[0]
          elsif values.size > 1
            values = { comparison => values }
          end
      end
      
      return field, values
    end
    
    def self.comparison_for( str )
      case str
        when "lt"; "$lte"
        when "gt"; "$gte"
        when "eq"; "=="
        else; "$in"
      end
    end
  end
end