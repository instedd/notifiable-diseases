@Charts ?= {}

class @Charts.Map extends @Charts.Base
  default_thresholds = {
    lower: 10
    upper: 40
  }

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
    fieldLabel = @field().label
    "Events by #{fieldLabel}"

  field: () =>
    @fieldsCollection().find(@mappingField)

  groupingField: () =>
    if @mappingField == 'location' then 'admin_level' else "#{@mappingField}_admin_level"

  applyToQuery: (query, filters) =>
    drawn_level = @.groupingLevel(filters)
    grouping = {}
    grouping[@groupingField()] = drawn_level
    query.group_by = [grouping]

    [@numeratorFor(query), @denominatorFor(query)]

  getSeries: (report, data) =>
    positives = data[0].tests
    denominators = data[1].tests

    positivesById = _.indexBy positives, @mappingField
    _.each denominators, (node) =>
      evt = positivesById[node[@mappingField]]
      node.positive = (evt?.count || 0)
      node.percentage = (node.positive) / node.count

    denominators

  getCSV: (report, series, callback) ->
    locationField = report.fieldsCollection().find(@mappingField)
    allLocationIds = _.uniq _.map series, (s) => s[@mappingField]
    locationField.locations.details(allLocationIds, ancestors: true).success (data) =>
      locations = _.indexBy data, "id"
      rows = [["Location", "Positive cases", "Total cases"]]
      for serie in series
        locationId = serie[@mappingField]
        locationName = locationField.getFullLocationPath(locations[locationId])
        rows.push [locationName, serie.positive, serie.count]
      callback(rows)

  groupingLevel: (filters) =>
    location_filter = _.find(filters, name: @mappingField)
    if location_filter && !location_filter.empty()
      Math.min(@field().getMaxPolygonLevel(), location_filter.adminLevel() + 1)
    else
      0

  groupingInfo: (filters) =>
    location_filter = _.find(filters, name: @mappingField)
    selected = location_filter?.selectedId()

    field: @groupingField()
    parents: (if selected then [selected] else [])
    level: @groupingLevel(filters)

  startRendering: (q) ->
    @renderingDeferred = q.defer()
    @renderingDeferred.promise

  doneRendering: (q) ->
    @renderingDeferred.resolve()
