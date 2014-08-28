angular.module('ndApp')
  .factory 'Map', (Cdx, FieldsService) ->
    class Map
      constructor: ->
        @kind = 'Map'

      @deserialize: (data) ->
        new Map

      isConfigurable: ->
        false

      applyToQuery: (query, filters) =>
        drawn_level = @.groupingLevel(filters)
        query.group_by = [ {"admin_level": drawn_level} ]

      getSeries: (report, data) ->
        data.events
        
      getCSV: (series) ->
        rows = []
        rows.push ["Location", "Results"]
        for serie in series
          rows.push [serie.location, serie.count]
        rows

      groupingLevel: (filters) ->
        location_filter = _.find(filters, (f) -> f.name == "location")
        filtered_level = location_filter && location_filter.adminLevel()
        if (filtered_level)
          drawn_level = Math.min(2, filtered_level + 1)
        else
          drawn_level = 1