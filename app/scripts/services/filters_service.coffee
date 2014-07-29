angular.module('ndApp')
  .service 'FiltersService', ->
    filters = []

    filters: ->
      filters

    applyFilters: (query) ->
      for filter in filters
        switch filter.kind
          when "Date"
            query.since = filter.since
            query.until = filter.until

      query
