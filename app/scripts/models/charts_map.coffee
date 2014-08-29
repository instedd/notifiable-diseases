angular.module('ndApp')
  .factory 'Map', (Cdx, FieldsService, settings) ->
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
        max_available_polygon_level = _.max(_.keys(settings.polygons))
        location_filter = _.find(filters, (f) -> f.name == "location")
        
        filtered_level = location_filter && location_filter.adminLevel()
        if (filtered_level)
          drawn_level = Math.min(max_available_polygon_level, filtered_level + 1)
        else
          drawn_level = 1