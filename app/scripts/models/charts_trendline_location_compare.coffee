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

  applyToQuery: (query, filters) ->
    query.group_by = @dateGrouping
    firstQuery = query
    secondQuery = _.cloneDeep firstQuery
    targetLocation = @getCompareToLocation(filters)
    if targetLocation
      secondQuery[@compareToLocationField] = targetLocation.id
      return [firstQuery, secondQuery]

  getSeries: (report, data) ->
    if !(data[1] && @getCompareToLocation(report.filters))
      return @getSimpleSeries(data[0].events)

    thisLocationEvents = data[0].events
    otherLocationEvents = data[1].events

    @sortData thisLocationEvents
    @sortData otherLocationEvents

    rows = []

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
        rows.push [thisData.start_time, thisData.count, 0]
        thisIndex += 1
      else if otherData && !thisData
        rows.push [otherData.start_time, 0, otherData.count]
        otherIndex += 1
      else
        thisStartedAt = thisData.start_time
        otherStartedAt = otherData.start_time

        if thisStartedAt == otherStartedAt
          rows.push [thisData.start_time, thisData.count, otherData.count]
          thisIndex += 1
          otherIndex += 1
        else if thisStartedAt < otherStartedAt
          rows.push [thisData.start_time, thisData.count, 0]
          thisIndex += 1
        else #  thisStartedAt > otherStartedAt
          rows.push [otherData.start_time, 0, otherData.count]
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
    locationId = locationFilter?.location?.id
    if locationId
      parentLocations = @fieldsCollection().getParentLocations @compareToLocationField, locationId
      myLevel = parseInt(@compareToLocation)
      _.find parentLocations, (loc) -> loc.level == myLevel
    else
      null
