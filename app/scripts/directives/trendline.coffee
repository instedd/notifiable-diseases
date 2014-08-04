angular.module('ndApp')
  .directive 'ndTrendline', () ->
    {
      restrict: 'E'
      scope:
        series: '='
        title: '='
      template: '<div google-chart chart="chart" class=\'nd-chart col-md-9\'/>'
      link: (scope, element, attrs) ->
        scope.$watchCollection('series', () ->
          if scope.series
            scope.chart = chart_for(scope.series, scope.title)
        )
    }

chart_for = (series, title) =>
  cols = [id: "date", label: "Date", type: "string", p: {}]
  for col in series.cols
    cols.push id: col, label: col, type: "number", p: {}

  rows = []
  for row in series.rows
    c = [v: row[0]]
    for value in row.slice(1)
      c.push
        v: value
        f: "#{value} events"
    rows.push c: c

  {
    type: "AreaChart"
    data:
      cols: cols
      rows: rows
    options:
      title: title
      isStacked: "true"
      fill: 20
      displayExactValues: true
      vAxis:
        title: "Event count"
        gridlines:
          count: 6
      hAxis:
        title: "Date"
    formatters: {}
    displayed: true
  }
