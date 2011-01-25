# ruby-ext-js

Provides ultra-basic classes for translating Ext.js GET params to Postgres (via Datamapper) and MongoDB (via Mongood) query opts with sensible default limits.

Examples:

## MongoDB

    class PullRequests < ExtJs::Mongo
      def self.allowed_filters
        ["state"]
      end
    end
    
    mongo = PullRequests.new( params )
    mongo.conditions # search conditions
    mongo.options # pagination and sorting options

## Postgres

(Implementation and API will change significantly in the future, don't use this yet.)

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

# Version history

Version number conventions: Patch-level bumps for bug fixes, minor-level bumps for changes that break backwards-compatibility, major-level bumps for major new features.

## 0.3.2

* Respect local time offset for `ExtJs::Mongo` date range filters.

## 0.3.1

* Use `Time.utc` instead of `Date` for `ExtJs::Mongo` date range filters.

## 0.3.0

* `ExtJs::Mongo` now supports 'date' filter params with "gt" and "lt" params.

## 0.2.1

* `ExtJs::Mongo.options` fixes.

## 0.2.0

* `ExtJs::Mongo.conditions` now returns a hash with string keys only instead of mixed string / symbol keys for better consistency with the [MongoDB Ruby driver](http://api.mongodb.org/ruby/1.2.0/index.html)

## 0.1.0

* All-new API for `ExtJs::Mongo` to match with MongoDB's Ruby drivers better.

## 0.0.1

* Initial release. Basic Postgres / Mongo adapters.

# Copyright

Copyright (c) 2011 CrowdFlower. See LICENSE.txt for
further details.
