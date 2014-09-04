angular.module('ndApp')
  .factory 'Map', (Cdx, FieldsService, settings) ->
    class Map

      default_thersholds = {
        min: 10
        max: 50
      }

      default_thersholds_max = default_thersholds.max + 10

      constructor: (thresholds, thresholds_max)->
        @kind = 'Map'
        @thresholds = thresholds || default_thersholds
        @thresholds_max = thresholds_max || default_thersholds_max

      @deserialize: (data) ->
        new Map(data.thresholds, data.thresholds_max)

      isConfigurable: ->
        true

      applyToQuery: (query, filters) =>
        drawn_level = @.groupingLevel(filters)
        query.group_by = [ {"admin_level": drawn_level} ]
        [query]

      getSeries: (report, data) =>
        events = data[0].events
        @.update_thresholds_max(events)
        events

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

      update_thresholds_max: (events) ->
        # hack :(
        # values equal to the yellow threshold will show a red marker
        # if we set max = top_event.count, the top marker will always
        # be shown in red.
        top_event = _.max(events, (e) -> e.count)
        @thresholds_max = Math.max(default_thersholds_max, top_event.count + 10)

