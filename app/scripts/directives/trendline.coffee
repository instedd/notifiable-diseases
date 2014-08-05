angular.module('ndApp')
  .directive 'ndTrendline', () ->
    {
      restrict: 'E'
      scope:
        series: '='
        title: '='
      template: '<div google-chart chart="chart" class="nd-chart col-md-9"></div>'
      link: (scope, element, attrs) ->
        scope.chart =
          type: "AreaChart"
          data:
            cols: [
              {id: "date", label: "Date", type: "string"},
              {id: "count", label: "Count", type: "number"},
            ]
            rows: []
          options:
            title: scope.title
            isStacked: "true"
            fill: 20
            displayExactValues: true
            vAxis:
              title: "Event count"
              gridlines:
                count: 6
            hAxis:
              title: "Date"
            animation:
              duration: 1000
              easing: 'out'
          formatters: {}
          displayed: true

        scope.$watchCollection('series', () ->
          if scope.series
            updateChart(scope.chart, scope.series, scope.title)
        )
    }

updateChart = (chart, series, title) =>
  cols = []
  cols.push id: "date", label: "Date", type: "string"
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
          f: "#{value} events"
      else
        c.push v: undefined
      i += 1

    rows.push c: c

  chart.data = cols: cols, rows: rows
