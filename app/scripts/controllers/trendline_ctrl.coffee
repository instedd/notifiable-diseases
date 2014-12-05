'use strict'

angular.module('ndApp')
  .controller 'TrendlineCtrl', ($scope, $timeout, $element) ->
    $scope.offset = 0
    $scope.title = $scope.chart.description($scope.currentReport)
    $scope.chartData = { colors: [], cols: [], rows: [] }
    $scope.computedInfo = null

    $scope.moveOffset = (step) ->
      return if not $scope.canMoveOffset(step)
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

    update = ->
      if $scope.series
        $scope.offset = 0
        $scope.computedInfo = compute $scope.series
        render()

    render = ->
      $scope.comparison = not $scope.chart.isStacked()
      $scope.grouping = $scope.chart.grouping
      $scope.chartData =
        cols: $scope.computedInfo.cols
        rows: sliceRows($scope.computedInfo.rows, $scope.offset)

    compute = (series) =>
      return unless series

      cols = []
      cols.push id: "date", label: "Date", type: "string"

      # If there are no rows (so, no cols), we return an empty set to avoid
      # getting an error from Google
      if series.cols.length == 0
        cols.push id: "count", label: "Count", type: "number"

        return cols: cols, rows: [], colors: COLORS, total: 0

      for col in series.cols
        cols.push id: col, label: col, type: "number"

      rows = []
      for row in series.rows
        c = [v: row[0]]

        i = 0
        while i < series.cols.length
          value = row[i + 1]
          if value
            c.push
              v: value
              f: tooltipFor(value)
          else
            c.push v: 0
          i += 1

        rows.push c: c

      cols: cols
      rows: rows
      total: rows.length

    tooltipFor = (value) =>
      if $scope.chart.values == 'percentage'
        "#{(value * 100).toFixed(2)}% events"
      else
        "#{value} events"

    sliceRows = (rows, offset) ->
      start = rows.length - offset - 10
      end = rows.length - offset

      start = 0 if start < 0

      if end < 0
        rows.slice(start)
      else
        rows.slice(start, end)

    $scope.$watchCollection('series', update)
    $scope.$watch 'chart.description(currentReport)', ->
      $scope.title = $scope.chart.description($scope.currentReport)

