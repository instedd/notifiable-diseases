angular.module('ndApp')
  .directive 'ndTrendline', () ->
    {
      restrict: 'E'
      scope:
        series: '='
        title: '='
      template: '<div google-chart chart="chart" class="nd-chart"></div>'
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
            isStacked: true
            vAxis:
              title: "Event count"
              gridlines:
                count: 6
            hAxis:
              title: "Date"
            animation:
              duration: 600
              easing: 'out'

        scope.$watchCollection('series', () ->
          if scope.series
            updateChart(scope.chart, scope.series, scope.title)
        )
    }

COLORS = ["#3266CC", "#DC3918", "#FD9927", "#149618", "#991499", "#1899C6", "#DD4477", "#66AA1E", "#B82E2E", "#316395", "#994399", "#22AA99", "#ABAA22", "#6633CC"]

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
        c.push v: 0
      i += 1

    rows.push c: c

  colors = []
  for index in series.indices
    colors.push COLORS[index]

  chart.data.cols = cols
  chart.data.rows = rows
  chart.options.colors = colors
