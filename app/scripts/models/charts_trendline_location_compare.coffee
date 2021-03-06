@Charts ?= {}

class @Charts.Trendline.LocationCompareDisplay extends @Charts.Trendline.BaseDisplay

  constructor: (t) ->
    super(t)
    @compareToLocation = t.compareToLocation
    @compareToLocationField = t.compareToLocationField

  description: (report) ->
    location = @getCompareToLocation(report.filters)
    if location
      compareField = @fieldsCollection().find(@compareToLocationField)
      "#{super()}, compared to #{location.name} from #{compareField.label}"
    else
      super()

  applyToQuery: (query, filters) ->
    query.group_by = @dateGrouping
    firstQuery = query
    secondQuery = _.cloneDeep firstQuery
    targetLocation = @getCompareToLocation(filters)

    queries = if targetLocation
      secondQuery[@compareToLocationField] = targetLocation.id
      [firstQuery, secondQuery]
    else
      [firstQuery]

    if @values == 'percentage'
      denominatorQueries = _.map(queries, (q) => @denominatorFor(q))
      queries = _.map(queries, (q) => @numeratorFor(q))
      queries.concat(denominatorQueries)
    else
      queries


  getSeries: (report, data) ->
    sortedData = _.map(data, (d) => @sortData(d[@resource]))
    if @values == 'percentage' && sortedData.length > 2
      thisLocationRates =  @getRates(sortedData[0], sortedData[2])
      otherLocationRates = @getRates(sortedData[1], sortedData[3])
      @getLocationCompareSeries(report, thisLocationRates, otherLocationRates)
    else if @values == 'percentage'
      @getSimpleSeries(sortedData[0], sortedData[1])
    else if sortedData.length > 1
      @getLocationCompareSeries(report, sortedData[0], sortedData[1])
    else
      @getSimpleSeries(sortedData[0])


  getLocationCompareSeries: (report, thisLocationEvents, otherLocationEvents) ->
    rows = []
    countField = if @values == 'percentage' then 'rate' else 'count'

    # Traverse both lists at the same time, always advancing the one
    # that has the lowest start_time value (similar to a merge sort).
    thisIndex = 0
    otherIndex = 0

    while true
      thisData = thisLocationEvents[thisIndex]
      otherData = otherLocationEvents[otherIndex]

      if !thisData && !otherData
        break

      if thisData && !otherData
        rows.push [thisData[@timeField], thisData[countField], 0]
        thisIndex += 1
      else if otherData && !thisData
        rows.push [otherData[@timeField], 0, otherData[countField]]
        otherIndex += 1
      else
        thisStartedAt = thisData[@timeField]
        otherStartedAt = otherData[@timeField]

        if thisStartedAt == otherStartedAt
          rows.push [thisData[@timeField], thisData[countField], otherData[countField]]
          thisIndex += 1
          otherIndex += 1
        else if thisStartedAt < otherStartedAt
          rows.push [thisData[@timeField], thisData[countField], 0]
          thisIndex += 1
        else #  thisStartedAt > otherStartedAt
          rows.push [otherData[@timeField], 0, otherData[countField]]
          otherIndex += 1

    filterLocation = @getFilterLocation(report.filters)
    targetLocation = @getCompareToLocation(report.filters)

    cols:
      ["#{filterLocation.name} events", "#{targetLocation.name} events"]
    rows:
      rows


  findLocationFilter: (filters) ->
    _.find filters, name: @compareToLocationField

  getFilterLocation: (filters) ->
    @findLocationFilter(filters)?.location

  getCompareToLocation: (filters) ->
    locationFilter = @findLocationFilter(filters)
    if locationFilter?.location?.id
      parentLocations = @fieldsCollection().find(@compareToLocationField).getParentLocations(locationFilter.location)
      myLevel = parseInt(@compareToLocation)
      _.find parentLocations, (loc) -> loc.level == myLevel
    else
      null
