@Charts ?= {}

class @Charts.Map
  default_thersholds = {
    lower: 10
    upper: 50
  }

  default_thersholds_max = default_thersholds.upper + 10

  fieldLevels = {}

  @setAvailablePolygonLevels: (field_levels) ->
    fieldLevels = field_levels

  getMaxPolygonLevel = (field) ->
    fieldLevels[field] || 0

  constructor: (fieldsCollection) ->
    @kind = 'Map'
    @fieldsCollection = () -> fieldsCollection
    @mappingField = fieldsCollection.allLocation()[0]?.name
    @thresholds = default_thersholds
    @thresholds_max = default_thersholds_max

  initializeFrom: (data) ->
    @thresholds = _.clone data.thresholds
    @thresholds_max = data.thresholds_max
    @mappingField = data.mappingField
    @

  toJSON: ->
    @

  isConfigurable: ->
    true

  applyToQuery: (query, filters) =>
    drawn_level = @.groupingLevel(filters)
    grouping_field = if @mappingField == 'location' then 'admin_level' else "#{@mappingField}_admin_level"
    grouping = {}
    grouping[grouping_field] = drawn_level
    query.group_by = [grouping]
    [query]

  getSeries: (report, data) =>
    events = data[0].events
    @updateThresholdsMax(events)
    events

  getCSV: (report, series) ->
    locationField = report.fieldsCollection().find(@mappingField)
    rows = []
    rows.push ["Location", "Results"]
    for serie in series
      if locationField
        location = locationField.locations[serie.location]
        locationName = locationField.getFullLocationPath(location)
      else
        locationName = serie.location
      rows.push [locationName, serie.count]
    rows

  groupingLevel: (filters) ->
    location_filter = _.find(filters, name: @mappingField)

    filtered_level = location_filter && location_filter.adminLevel()
    if (filtered_level)
      drawn_level = Math.min(getMaxPolygonLevel(@mappingField), filtered_level + 1)
    else
      drawn_level = 1

  updateThresholdsMax: (events) ->
    # hack :(
    # values equal to the yellow threshold will show a red marker
    # if we set max = top_event.count, the top marker will always
    # be shown in red.
    top_count = _.max _.map(events, 'count')
    @thresholds_max = Math.max(default_thersholds_max, top_count + 10)

