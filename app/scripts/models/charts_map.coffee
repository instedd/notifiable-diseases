angular.module('ndApp')
  .factory 'Map', (Cdx, FieldsService, settings) ->
    class Map
      constructor: (thresholds)->
        @kind = 'Map'
        @thresholds = thresholds || {
          min: 10
          max: 50
        }

      @deserialize: (data) ->
        new Map(data.thresholds)

      isConfigurable: ->
        true

      applyToQuery: (query, filters) =>
        drawn_level = @.groupingLevel(filters)
        query.group_by = [ {"admin_level": drawn_level} ]
        [query]

      getSeries: (report, data) ->
        data[0].events

      getCSV: (series) ->
        rows = []
        rows.push ["Location", "Results"]
        for serie in series
          rows.push [serie.location, serie.count]
        rows

      groupingLevel: (filters) ->
        location_filter = _.find(filters, (f) -> f.name == "location")
        max_available_polygon_level = _.max(_.keys(settings.polygons))

        filtered_level = location_filter && location_filter.adminLevel()
        if (filtered_level)
          drawn_level = Math.min(max_available_polygon_level, filtered_level + 1)
        else
          drawn_level = 1
