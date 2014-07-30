format_for_chart = (result) =>
  _.map(result, (g) ->
    c: [
         { v: g.created_at },
         { 
           v: g.count,
           f: g.count + " events"
         }
       ]
  )

chart_for = (data_str, title) =>
  {
    type: "AreaChart"
    cssStyle: "height:400px; width:700px;"
    data:
      cols: [
        { id: "year",  label: "Year",   type: "string", p: {} },
        { id: "count", label: "Events", type: "number", p: {} }
      ]
      rows: format_for_chart(data_str)
    options:
      title: title
      isStacked: "true"
      fill: 20
      displayExactValues: true
      vAxis:
        title: "Sales unit"
        gridlines:
          count: 6
      hAxis:
        title: "Date"
    formatters: {}
    displayed: true
  }

angular.module('ndApp')
  .directive 'ndTrendline', () ->
    {
      restrict: 'E'
      scope:
        series: '='
        title: '='
      template: '<div google-chart chart="chart" style="{{chart.cssStyle}}"/>'
      link: (scope, element, attrs) ->
        scope.$watchCollection('series', () ->
          scope.chart = chart_for(scope.series, scope.title)
        )
    }