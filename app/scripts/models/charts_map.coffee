@Charts ?= {}

class @Charts.Map
  default_thresholds = {
    lower: 10
    upper: 40
  }

  fieldLevels = {}

  @setAvailablePolygonLevels: (field_levels) ->
    fieldLevels = field_levels

  getMaxPolygonLevel = (field) ->
    fieldLevels[field] || 0

  constructor: (fieldsCollection) ->
    @kind = 'Map'
    @fieldsCollection = () -> fieldsCollection
    @mappingField = fieldsCollection.allLocation()[0]?.name
    @thresholds = default_thresholds
    @validResults = _.map fieldsCollection.result_field().validResults(), 'value'

  initializeFrom: (data) ->
    @thresholds = _.clone data.thresholds
    @mappingField = data.mappingField
    @

  toJSON: ->
    @

  isConfigurable: ->
    true

  groupingField: () =>
    if @mappingField == 'location' then 'admin_level' else "#{@mappingField}_admin_level"

  applyToQuery: (query, filters) =>
    drawn_level = @.groupingLevel(filters)
    grouping = {}
    grouping[@groupingField()] = drawn_level
    query.group_by = [grouping]

    denominator = _.cloneDeep query
    denominator.result = @validResults
    [query, denominator]

  getSeries: (report, data) =>
    events = data[0].events
    denominators = data[1].events

    denominatorsById = _.indexBy denominators, @groupingField()
    _.each events, (evt) =>
      node = denominatorsById[evt[@groupingField()]]
      node.positive = evt.count
      node.percentage = evt.count / node.count

    denominators

  getCSV: (report, series) ->
    locationField = report.fieldsCollection().find(@mappingField)
    rows = []
    rows.push ["Location", "Positive cases", "Total cases"]
    for serie in series
      serieValue = serie[@mappingField]
      if locationField
        location = locationField.locations[serieValue]
        locationName = locationField.getFullLocationPath(location)
      else
        locationName = serie[serieValue]
      rows.push [locationName, serie.positive, serie.count]
    rows

  groupingLevel: (filters) ->
    location_filter = _.find(filters, name: @mappingField)

    filtered_level = location_filter && location_filter.adminLevel()
    if (filtered_level)
      drawn_level = Math.min(getMaxPolygonLevel(@mappingField), filtered_level + 1)
    else
      drawn_level = 1

  startRendering: (q) ->
    @renderingDeferred = q.defer()
    @renderingDeferred.promise

  doneRendering: (q) ->
    @renderingDeferred.resolve()
