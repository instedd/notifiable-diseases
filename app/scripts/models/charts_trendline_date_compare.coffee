@Charts ?= {}

class @Charts.Trendline.DateCompareDisplay extends @Charts.Trendline.BaseDisplay

  constructor: (t) ->
    super(t)
    @compareToDate = t.compareToDate
    throw "Unknown compare to value: #{t.compareToDate}" unless @compareToDate == 'previous_year'

  description: () ->
    "#{super()}, compared to previous year"

  getDateFilter: (filters) ->
    _.find filters, (filter) -> filter.name == FieldsCollection.fieldNames.date

  applyToQuery: (query, filters) ->
    query.group_by = @dateGrouping
    dateFilter = @getDateFilter filters
    if dateFilter
      since = moment(dateFilter.since).add(-1, 'years')
      query.since = since.format("YYYY-MM-DD")

    [query]

  getSeries: (report, data) ->
    data = data[0].events
    @sortData data

    # First, index data by start_time
    indexedData = {}
    for event in data
      indexedData[event.start_time] = event.count

    intervalFormat = @intervalFormat()

    # Now check if there's a date filter. If so, we
    # will skip rows until we are after the "since" date.
    dateFilter = @getDateFilter(report.filters)

    since = dateFilter?.since
    since = moment(since) if since

    # Get the maximum date we want to display: either the one in
    # the date filter, or the current date.
    max = dateFilter?.until
    max = if max then moment(max) else moment()
    max = max.format(intervalFormat)

    # Next, for each event we create two results, one for the
    # previous year and one for the current one
    rows = []
    for event in data
      date = event.start_time
      currentDate = @moment(date)

      previousDate = moment(currentDate).add(-1, 'years').format(intervalFormat)
      nextDate = moment(currentDate).add(1, 'years').format(intervalFormat)

      # If we are still behind the "since" date, skip this event
      if since && currentDate.diff(since) < 0
        continue

      previousYearCount = indexedData[previousDate]
      previousYearCount ?= 0

      rows.push [date, event.count, previousYearCount]

      # We also need to check the next year: if there's no data
      # we fill it with this year's value, but only if it's before
      # the maximum date (either from the date filter or the current date).
      if nextDate <= max
        nextYearCount = indexedData[nextDate]
        unless nextYearCount
          rows.push [nextDate, 0, event.count]

    rows.sort (x, y) ->
      if x[0] < y[0]
        -1
      else if x[0] > y[0]
        1
      else
        0

    cols:
      ["Events", "Previous year events"]
    rows:
      rows
