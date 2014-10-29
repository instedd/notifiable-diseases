@Charts ?= {}

class @Charts.Trendline
  constructor: (fieldsCollection) ->
    @kind = 'Trendline'
    @fieldsCollection = () -> fieldsCollection
    @display = 'simple'
    @grouping = 'year'
    @compareToDate = 'previous_year'
    @splitField = fieldsCollection.allEnum()[0]?.name
    @compareToLocationField = fieldsCollection.allLocation()[0]?.name
    @values = 'count'

  initializeFrom: (data) ->
    @display = data.display
    @splitField = data.splitField
    @grouping = data.grouping
    @compareToDate = data.compareToDate
    @compareToLocation = data.compareToLocation
    @compareToLocationField = data.compareToLocationField
    @values = data.values
    @

  toJSON: ->
    {
      kind: @kind
      display: @display
      splitField: @splitField
      grouping: @grouping
      compareToDate: @compareToDate
      compareToLocation: @compareToLocation
      compareToLocationField: @compareToLocationField
      values: @values
    }

  isConfigurable: ->
    true

  vizType: ->
    switch @display
      when 'compareToDate', 'compareToLocation'
        'LineChart'
      else
        'AreaChart'

  isStacked: ->
    @display != 'compareToDate' && @display != 'compareToLocation'

  description: (report) ->
    desc = "Events grouped by #{@grouping}"
    switch @display
      when 'split'
        splitField = @fieldsCollection().find(@splitField)
        desc += ", split by #{splitField?.label.toLowerCase()}"
      when 'compareToDate'
        switch @compareToDate
          when 'previous_year'
            desc += ", compared to previous year"
          else
            throw "Unknown compare to value: #{@compareToDate}"
      when 'compareToLocation'
        location = @getCompareToLocation(report.filters)
        if location
          compareField = @fieldsCollection().find(@compareToLocationField)
          desc += ", compared to #{location.name} from #{compareField.label}"
    desc

  applyToQuery: (query, filters) ->
    date_grouping = "#{@grouping}(#{FieldsCollection.fieldNames.date})"
    switch @display
      when 'simple'
        query.group_by = date_grouping
      when 'split'
        query.group_by = [date_grouping, @splitField]
      when 'compareToDate'
        query.group_by = date_grouping
        switch @compareToDate
          when 'previous_year'
            dateFilter = @getDateFilter filters
            if dateFilter
              since = moment(dateFilter.since).add(-1, 'years')
              query.since = since.format("YYYY-MM-DD")
          else
            throw "Unknown compare to value: #{@compareToDate}"
      when 'compareToLocation'
        query.group_by = date_grouping
        firstQuery = query
        secondQuery = _.cloneDeep firstQuery
        targetLocation = @getCompareToLocation(filters)
        if targetLocation
          secondQuery[@compareToLocationField] = targetLocation.id
          return [firstQuery, secondQuery]
      else
        throw "Unknown display: #{@display}"

    [query]

  getSeries: (report, data) ->
    series = switch @display
             when 'simple'
               @getSimpleSeries(data[0].events)
             when 'split'
               @getSplitSeries(report, data[0].events)
             when 'compareToDate'
               @getCompareToDateSeries(report, data[0].events)
             when 'compareToLocation'
               if data[1] && @getCompareToLocation(report.filters)
                 @getCompareToLocationSeries(report, data[0].events, data[1].events)
               else
                 @getSimpleSeries(data[0].events)
             else
               throw "Unknown display: #{@display}"
    series.interval = @grouping
    @extendToDateBounds(report, series)
    series.rows = @fillGaps series

    series

  extendToDateBounds: (report, series) ->
    createRow = (firstValue) ->
      row = [firstValue]
      i = 0
      while i < cols.length
        row.push 0
        i += 1
      row

    rows = series.rows
    cols = series.cols
    intervalFormat = @intervalFormat()

    dateFilter = report.findFilter FieldsCollection.fieldNames.date
    if dateFilter

      sinceDate = moment(dateFilter.since).format(intervalFormat)
      untilDate = moment(dateFilter.until).format(intervalFormat)

      if rows.length == 0
        rows.push createRow(sinceDate)
        rows.push createRow(untilDate)
        return

      firstRow = rows[0]
      lastRow = rows[rows.length - 1]

      if firstRow
        firstDate = @moment(firstRow[0]).format(intervalFormat)
        if firstDate != sinceDate
          rows.splice 0, 0, createRow(sinceDate)

        lastDate = @moment(lastRow[0]).format(intervalFormat)
        if lastDate != untilDate
          rows.push createRow(untilDate)
    else if rows.length > 0
      now = moment().format(intervalFormat)

      lastRow = rows[rows.length - 1]
      lastDate = @moment(lastRow[0]).format(intervalFormat)

      if lastDate != now
        rows.push createRow(now)

  getSimpleSeries: (data) ->
    @sortData data

    cols:
      ["Events"]
    rows:
      _.map data, (value) ->
        [value.start_time, value.count]

  getSplitSeries: (report, data) ->
    @sortSplitData data

    options = report.fieldOptionsFor(@splitField)

    cols = _.map options, (option) -> option.label
    allValues = _.map options, (option) -> option.value

    # Check which column indices we found: this basically tells
    # us which columns have values in the results, so later we
    # can discard those that have no values.
    foundIndices = []

    rows = []

    i = 0
    len = data.length
    while i < len
      item = data[i]

      date = item.start_time
      row = [date]

      # Traverse all items that follow (including this one) as long
      # as their date is the same as this one
      j = i
      while j < len
        other_item = data[j]
        other_date = other_item.start_time
        if other_date != date
          break

        index = _.indexOf allValues, other_item[@splitField]

        # This is a sanity check: the index shouldn't be -1 if all data is correct
        if index != -1
          foundIndices[index] = true
          row[index + 1] = other_item.count

        j += 1

      rows.push row
      i = j

    # Convert the indices to numbers
    indices = []
    for i in [0 ... foundIndices.length]
      indices.push i if foundIndices[i]
    foundIndices = indices

    # Build new rows with only indices for the found indices
    newRows = []
    for row in rows
      newRow = []
      newRow.push row[0]
      for index in foundIndices
        newRow.push row[index + 1]
      newRows.push newRow

    # The same goes for the cols
    newCols = []
    for index in foundIndices
      newCols.push cols[index]

    cols: newCols, rows: newRows, indices: foundIndices

  getCompareToDateSeries: (report, data) ->
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

  intervalFormat: ->
    switch @grouping
      when "day"
        "YYYY-MM-DD"
      when "week"
        "gggg-[W]WW"
      when "month"
        "YYYY-MM"
      when "year"
        "YYYY"

  moment: (string) ->
    switch @grouping
      when "day"
        moment(string)
      when "week"
        moment(string)
      when "month"
        moment("#{string}-01")
      when "year"
        moment("#{string}-01-01")

  getCompareToLocationSeries: (report, thisLocationEvents, otherLocationEvents) ->
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

  getCSV: (report, series) ->
    rows = []
    rows.push ["Date"].concat(series.cols)
    for row in series.rows
      rows.push _.map row, (v) -> if v then v else 0
    rows

  sortData: (data) ->
    data.sort (x, y) =>
      if x.start_time < y.start_time
        -1
      else if x.start_time > y.start_time
        1
      else
        0

  sortSplitData: (data) ->
    data.sort (x, y) =>
      if x.start_time < y.start_time
        -1
      else if x.start_time > y.start_time
        1
      else if x[@splitField] < y[@splitField]
        -1
      else if x[@splitField] > y[@splitField]
        1
      else
        0

  getDateFilter: (filters) ->
    _.find filters, (filter) -> filter.name == FieldsCollection.fieldNames.date

  fillGaps: (series) ->
    rows = series.rows
    return rows if rows.length < 2

    interval = series.interval
    cols_num = series.cols.length - 1

    new_rows = []
    i = 0
    while i < rows.length - 1
      row = rows[i]
      thisRow = row[0]
      nextRow = rows[i + 1][0]

      new_rows.push row

      nextValue = thisRow

      while true
        nextValue = @nextDate(nextValue, interval)
        if nextValue >= nextRow
          break
        else
          emptyRow = [nextValue]
          for j in [0 .. cols_num]
            emptyRow.push 0
          new_rows.push emptyRow

      i += 1

    new_rows.push rows[rows.length - 1]
    new_rows

  nextDate: (value, interval) ->
    switch interval
      when "year"
        @nextYear(value)
      when "month"
        @nextMonth(value)
      when "week"
        @nextWeek(value)
      when "day"
        @nextDay(value)
      else
        throw "Uknknown interval: #{interval}"

  nextYear: (value) ->
    (parseInt(value) + 1).toString()

  nextMonth: (value) ->
    [year, month] = value.split("-")
    year = parseInt(year)
    month = parseInt(month)
    month += 1
    if month == 13
      month = 1
      year += 1
    "#{year}-#{@pad(month)}"

  nextWeek: (value) ->
    [year, week] = value.split("-W")
    year = parseInt(year)
    week = parseInt(week)

    # Easy case: week is less than 50, there's no problem adding one
    if week < 50
      "#{year}-W#{@pad(week + 1)}"
    else
      date = moment().year(year).isoWeek(week).add(1, 'weeks')
      # Apparently when week is 1 moment doesn't increase the year...
      if date.isoWeek() == 1
        "#{year + 1}-W01"
      else
        "#{year}-W#{@pad(week + 1)}"

  nextDay: (value) ->
    [year, month, day] = value.split("-")
    year = parseInt(year)
    month = parseInt(month)
    day = parseInt(day)

    # Easy case: day is less than 28, there's no problem adding one
    if day < 28
      "#{year}-#{@pad(month)}-#{@pad(day + 1)}"
    else
      moment().year(year).month(month - 1).date(day).add(1, 'days').format("YYYY-MM-DD")

  pad: (num) ->
    if num < 10
      "0#{num}"
    else
      "#{num}"

  startRendering: (q) -> q.when(true)
