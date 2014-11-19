'use strict'

angular.module('ndApp')
  .controller 'TrendlineCtrl', ($scope, $timeout, $element) ->
    $scope.offset = 0
    $scope.viz =
      type: "AreaChart"
      data:
        cols: [
          {id: "date", label: "Date", type: "string"},
          {id: "count", label: "Count", type: "number"},
        ]
        rows: []
      options:
        title: $scope.chart.description($scope.currentReport)
        isStacked: true
        width: '100%'
        height: 320
        vAxis:
          title: "Event count"
          minValue: 0
        hAxis:
          title: "Date"
          maxAlternation: 1
          slantedText: true
          textStyle:
            fontSize: 9
        animation:
          duration: 600
          easing: 'out'
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

    # container = d3.select($('stack-chart-container', $element)[0])
    # chart = StackChart().width(500).height(200)
    # try
    #   container.call(chart, [], [])
    # catch e

    render = ->
      $scope.viz.data.rows = sliceRows($scope.computedInfo.rows, $scope.offset)

      # The angular chart directive sometimes doesn't realize data changes, so
      # we force a window reisze to force a redraw.
      $timeout ->
        window.dispatchEvent(new Event('resize'))

      # console.log $scope.computedInfo.rows
      # chart.redraw($scope.computedInfo.rows, [])

    computeAndRender = ->
      if $scope.series
        $scope.offset = 0
        $scope.computedInfo = compute $scope.series
        $scope.viz.options.colors = $scope.computedInfo.colors
        $scope.viz.options.isStacked = $scope.chart.isStacked()
        $scope.viz.type = $scope.chart.vizType()
        $scope.viz.data.cols = $scope.computedInfo.cols
        if $scope.chart.values == 'percentage'
          $scope.viz.options.vAxis.title = 'Event rate'
          $scope.viz.options.vAxis.format = '##.##%'
          $scope.viz.options.vAxis.maxValue = null
        else
          $scope.viz.options.vAxis.title = 'Event count'
          $scope.viz.options.vAxis.format = null
          $scope.viz.options.vAxis.maxValue = 4
        render()

    $scope.$watchCollection('series', computeAndRender)
    $scope.$watch 'chart.description(currentReport)', ->
      $scope.viz.options.title = $scope.chart.description($scope.currentReport)


    COLORS = ["#3266CC", "#DC3918", "#FD9927", "#149618", "#991499", "#1899C6", "#DD4477", "#66AA1E", "#B82E2E", "#316395", "#994399", "#22AA99", "#ABAA22", "#6633CC"]

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
