angular.module('ndApp')
  .directive 'ndTrendline', () ->
    {
      restrict: 'E'
      scope:
        series: '='
        title: '='
      template: '<div google-chart chart="chart" class=\'nd-trendline\'/>'
      link: (scope, element, attrs) ->
        scope.$watchCollection('series', () ->
          console.log scope.series
          scope.chart = chart_for(scope.series, scope.title)
        )
    }


format_for_chart = (series) =>
  _.map(series, (g) ->
    c: [
         { v: g.created_at },
         {
           v: g.count,
           f: g.count + " events"
         }
       ]
  )

chart_for = (series, title) =>
  {
    type: "AreaChart"
    data:
      cols: [
        { id: "year",  label: "Year",   type: "string", p: {} },
        { id: "count", label: "Events", type: "number", p: {} }
      ]
      rows: format_for_chart(series)
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
