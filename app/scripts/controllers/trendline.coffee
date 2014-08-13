'use strict'

angular.module('ndApp')
  .controller 'TrendlineCtrl', ($scope) ->
    $scope.offset = 0
    $scope.chart =
      type: "AreaChart"
      data:
        cols: [
          {id: "date", label: "Date", type: "string"},
          {id: "count", label: "Count", type: "number"},
        ]
        rows: []
      options:
        title: "Events"
        isStacked: true
        vAxis:
          title: "Event count"
          gridlines:
            count: 6
          viewWindow:
            min: 0
        hAxis:
          title: "Date"
          textStyle:
            fontSize: 9
        animation:
          duration: 600
          easing: 'out'
    $scope.computedInfo = null

    $scope.moveOffset = (step) ->
      if $scope.computedInfo
        $scope.offset += step
        $scope.offset = $scope.computedInfo.total - 10 if $scope.offset > $scope.computedInfo.total - 10
        $scope.offset = 0 if $scope.offset < 0
        render()

    $scope.canMoveOffset = (step) ->
      if $scope.computedInfo
        if step > 0
          $scope.offset < $scope.computedInfo.total - 10
        else
          $scope.offset > 0
      else
        false

    render = ->
      $scope.chart.data.rows = sliceRows($scope.computedInfo.rows, $scope.offset)

    computeAndRender = ->
      if $scope.series
        $scope.offset = 0
        $scope.computedInfo = compute $scope.series
        $scope.chart.options.colors = $scope.computedInfo.colors
        $scope.chart.data.cols = $scope.computedInfo.cols
        render()

    $scope.$watchCollection('series', computeAndRender)

COLORS = ["#3266CC", "#DC3918", "#FD9927", "#149618", "#991499", "#1899C6", "#DD4477", "#66AA1E", "#B82E2E", "#316395", "#994399", "#22AA99", "#ABAA22", "#6633CC"]

compute = (series) =>
  return unless series

  cols = []
  cols.push id: "date", label: "Date", type: "string"
  for col in series.cols
    cols.push id: col, label: col, type: "number"

  series_rows = fillGaps(series.rows, series.interval, series.cols.length - 1)

  rows = []
  for row in series_rows
    c = [v: row[0]]

    i = 0
    while i < series.cols.length
      value = row[i + 1]
      if value
        c.push
          v: value
          f: "#{value} events"
      else
        c.push v: 0
      i += 1

    rows.push c: c

  if series.indices
    colors = []
    for index in series.indices
      colors.push COLORS[index]
  else
    colors = COLORS

  cols: cols
  rows: rows
  colors: colors
  total: rows.length

sliceRows = (rows, offset) ->
  start = rows.length - offset - 10
  end = rows.length - offset

  start = 0 if start < 0

  if end < 0
    rows.slice(start)
  else
    rows.slice(start, end)

fillGaps = (rows, interval, cols_num) ->
  return rows if rows.length < 2

  new_rows = []
  i = 0
  while i < rows.length - 1
    row = rows[i]
    thisRow = row[0]
    nextRow = rows[i + 1][0]

    new_rows.push row

    nextValue = thisRow

    while true
      nextValue = nextDate(nextValue, interval)
      if nextValue == nextRow
        break
      else
        emptyRow = [nextValue]
        for j in [0 .. cols_num]
          emptyRow.push 0
        new_rows.push emptyRow

    i += 1

  new_rows

nextDate = (value, interval) ->
  switch interval
    when "year"
      nextYear(value)
    when "month"
      nextMonth(value)
    when "week"
      nextWeek(value)
    when "day"
      nextDay(value)
    else
      throw "Uknknown interval: #{interval}"

nextYear = (value) ->
  (parseInt(value) + 1).toString()

nextMonth = (value) ->
  [year, month] = value.split("-")
  year = parseInt(year)
  month = parseInt(month)
  month += 1
  if month == 13
    month = 1
    year += 1
  "#{year}-#{pad(month)}"

nextWeek = (value) ->
  [year, week] = value.split("-W")
  year = parseInt(year)
  week = parseInt(week)

  # Easy case: week is less than 50, there's no problem adding one
  if week < 50
    "#{year}-W#{pad(week + 1)}"
  else
    date = moment().year(year).isoWeek(week).add(1, 'weeks')
    # Apparently when week is 1 moment doesn't increase the year...
    if date.isoWeek() == 1
      "#{year + 1}-W01"
    else
      "#{year}-W#{pad(week + 1)}"

nextDay = (value) ->
  [year, month, day] = value.split("-")
  year = parseInt(year)
  month = parseInt(month)
  day = parseInt(day)

  # Easy case: day is less than 28, there's no problem adding one
  if day < 28
    "#{year}-#{pad(month)}-#{pad(day + 1)}"
  else
    moment().year(year).month(month - 1).date(day).add(1, 'days').format("YYYY-MM-DD")

pad = (num) ->
  if num < 10
    "0#{num}"
  else
    "#{num}"
