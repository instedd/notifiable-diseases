@Charts ?= {}

class @Charts.Trendline.BaseDisplay

  constructor: (@trendline) ->
    @dateGrouping = "#{@trendline.grouping}(#{FieldsCollection.fieldNames.date})"
    @denominatorFor = (q) -> @trendline.denominatorFor(q)
    @values = @trendline.values

  getSeries: (report, data) ->
    throw "Subclass responsibility"

  getExtendedSeries: (report, data) ->
    series = @getSeries(report, data)
    series.interval = @trendline.grouping
    @extendToDateBounds(report, series)
    series.rows = @fillGaps series
    series

  getSimpleSeries: (data, denominators) ->
    @sortData data
    @sortData denominators

    cols:
      ["Events"]
    rows:
      _.map @getRates(data, denominators), (value) ->
        [value.start_time, (if denominators? then value.rate else value.count)]

  getRates: (positives, denominators) ->
    return positives if not denominators?

    positivesIndex = 0
    denominatorsIndex = 0

    while positivesIndex < positives.length or denominatorsIndex < denominators.length

      positive = positives[positivesIndex]
      denominator = denominators[denominatorsIndex]

      if not positive? or positive.start_time > denominator.start_time
        denominator.rate = 0
        denominatorsIndex++
      else if positive.start_time == denominator.start_time
        denominator.rate = if denominator.count == 0 then 0 else positive.count / denominator.count
        positivesIndex++
        denominatorsIndex++
      else if positive.start_time < denominator.start_time
        positivesIndex++

    return denominators


  fieldsCollection: () ->
    @trendline.fieldsCollection()

  sortData: (data) ->
    return null if not data?
    data.sort (x, y) =>
      if x.start_time < y.start_time
        -1
      else if x.start_time > y.start_time
        1
      else
        0

  description: (report) ->
    "Events grouped by #{@trendline.grouping}"

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

  intervalFormat: ->
    switch @trendline.grouping
      when "day"
        "YYYY-MM-DD"
      when "week"
        "gggg-[W]WW"
      when "month"
        "YYYY-MM"
      when "year"
        "YYYY"

  moment: (string) ->
    switch @trendline.grouping
      when "day"
        moment(string)
      when "week"
        moment(string)
      when "month"
        moment("#{string}-01")
      when "year"
        moment("#{string}-01-01")


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
