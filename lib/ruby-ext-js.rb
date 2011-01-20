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
    MAX_PER_PAGE = 1000
    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 30
    
    def self.db_opts( params )
      opts = {}
      
      opts.merge! page_param( params )
      opts.merge! per_page_param( params )
      opts.merge! sort_param( params )
      opts.merge! search_param( params )
      
      opts
    end
    
    protected
    
    def self.allowed_filters
      []
    end
    
    def self.page_param( params )
      return { :page => DEFAULT_PAGE } unless params.key?( "start" ) && params.key?( "limit" )
      
      start = params["start"].to_i
      limit = per_page_param( params )[:per_page]
      
      { :page => ( start / limit ) + 1 }
    end
    
    def self.per_page_param( params )
      unless params.key?( "limit" ) && params["limit"].to_i > 0
        return { :per_page => DEFAULT_PER_PAGE }
      end
      { :per_page => [params["limit"].to_i, MAX_PER_PAGE].min }
    end
    
    def self.sort_param( params )
      return {} unless params.key?( "sort" )
      
      sort = params["sort"] ? params["sort"].to_sym : :id
      sort = params["dir"] =~ /desc/i ? sort.desc : sort.asc
      
      { :sort => sort }
    end
    
    def self.search_param( params )
      if params["filter"] && params["filter"]["0"]
        field = params["filter"]["0"]["field"].gsub(/[^\.\w\d_-]/, "").strip
        values = Array( params["filter"]["0"]["data"]["value"] )
        
        if values.size == 1
          values = values[0]
        else
          values = { "$in" => values }
        end
        
        unless field.blank? || !allowed_filters.include?( field ) || values.blank?
          return { field => values }
        end
      end
      {}
    end
  end
end