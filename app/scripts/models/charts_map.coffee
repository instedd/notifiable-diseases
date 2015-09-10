@Charts ?= {}

class @Charts.Map extends @Charts.Base
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
    super(fieldsCollection)
    @kind = 'Map'
    @mappingField = fieldsCollection.allLocation()[0]?.name
    @thresholds = default_thresholds

  initializeFrom: (data) ->
    @thresholds = _.clone data.thresholds
    @mappingField = data.mappingField
    @

  toJSON: ->
    @

  isConfigurable: ->
    true

  description: () =>
    fieldLabel = @fieldsCollection().find(@mappingField).label
    "Events by #{fieldLabel}"

  groupingField: () =>
    if @mappingField == 'location' then 'admin_level' else "#{@mappingField}_admin_level"

  applyToQuery: (query, filters) =>
    drawn_level = @.groupingLevel(filters)
    grouping = {}
    grouping[@groupingField()] = drawn_level
    query.group_by = [grouping]

    [@numeratorFor(query), @denominatorFor(query)]

  getSeries: (report, data) =>
    positives = data[0].events
    denominators = data[1].events

    positivesById = _.indexBy positives, @mappingField
    _.each denominators, (node) =>
      evt = positivesById[node[@mappingField]]
      node.positive = (evt?.count || 0)
      node.percentage = (node.positive) / node.count

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
      if location_filter.hasChildren()
        filtered_level + 1
      else
        filtered_level
    else
      drawn_level = 1

  startRendering: (q) ->
    @renderingDeferred = q.defer()
    @renderingDeferred.promise

  doneRendering: (q) ->
    @renderingDeferred.resolve()
