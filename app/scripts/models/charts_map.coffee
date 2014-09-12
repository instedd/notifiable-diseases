@Charts ?= {}

class @Charts.Map
  default_thersholds = {
    lower: 10
    upper: 50
  }

  default_thersholds_max = default_thersholds.upper + 10

  max_available_polygon_level = 5   # initialize at configuration time

  @setMaxAvailablePolygonLevel: (value) ->
    max_available_polygon_level = value

  constructor: (fieldsCollection) ->
    @kind = 'Map'
    @thresholds = default_thersholds
    @thresholds_max = default_thersholds_max

  initializeFrom: (data) ->
    @thresholds = _.clone data.thresholds
    @thresholds_max = data.thresholds_max
    @

  toJSON: ->
    @

  isConfigurable: ->
    true

  applyToQuery: (query, filters) =>
    drawn_level = @.groupingLevel(filters)
    query.group_by = [ {"admin_level": drawn_level} ]
    [query]

  getSeries: (report, data) =>
    events = data[0].events
    @updateThresholdsMax(events)
    events

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
      drawn_level = Math.min(max_available_polygon_level, filtered_level + 1)
    else
      drawn_level = 1

  updateThresholdsMax: (events) ->
    # hack :(
    # values equal to the yellow threshold will show a red marker
    # if we set max = top_event.count, the top marker will always
    # be shown in red.
    top_count = _.max _.map(events, 'count')
    @thresholds_max = Math.max(default_thersholds_max, top_count + 10)

