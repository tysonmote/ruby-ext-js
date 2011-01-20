# ruby-ext-js

Provides ultra-basic classes for translating Ext.js GET params to Postgres (via Datamapper) and MongoDB (via Mongood) query opts with sensible default limits.

Examples:

## Postgres

    module ExtJs
      class PullRequests < Postgres
        # Converts Ext.js' wacky params structure into a Postgres db query opts
        # hash. Supports filtering by PullRequests.state only
        def self.db_opts(params, opts = {})
          params[:dir] ||= "DESC" # Default to descending order
          
          db_opts = self.pagination_opts( params, {
            :max_offset => 5000, # Optional, prevent Postgres from shitting its pants
            :max_limit => 100
          }.merge( opts ))
          
          # Filters (the Ext filters hash is not pretty)
          filters = {}
          if params[:filter] && params[:filter]["0"] && params[:filter]["0"][:data]
            filters = case params[:filter]["0"][:data][:value]
              when "Rejected":   { :rejected => true }
              when "Approved":   { :rejected => false }
              when "Unreviewed": { :reviewed => nil }
            end
          end
          
          db_opts.merge filters
        end
      end
    end

## MongoDB

Mongo's a lot easier to work with:

    module ExtJs
      class PullRequests < Mongo
        def self.allowed_filters
          ["state"]
        end
      end
    end

# Specs

`ExtJs` was extracted from private code. Existing specs rely on private models, so there are no specs here yet. Specs will require DataMapper.

# Contributing
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

# Copyright

Copyright (c) 2011 CrowdFlower. See LICENSE.txt for
further details.
