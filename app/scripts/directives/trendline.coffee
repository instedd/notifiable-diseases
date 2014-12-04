angular.module('ndApp')
  .directive 'ndTrendline', ($window) ->
    {
      restrict: 'E'

      scope:
        chartdata: '='
        title: '='
        values: '='
        stacked: '='
        charttype: '='

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

        render = ->
          if scope.chartdata
            scope.chart.options.colors = scope.chartdata.colors
            scope.chart.options.isStacked = scope.stacked
            scope.chart.type = scope.charttype
            scope.chart.data.cols = scope.chartdata.cols
            if scope.values == 'percentage'
              scope.chart.options.vAxis.title = 'Event rate'
              scope.chart.options.vAxis.format = '##.##%'
              scope.chart.options.vAxis.maxValue = null
            else
              scope.chart.options.vAxis.title = 'Event count'
              scope.chart.options.vAxis.format = null
              scope.chart.options.vAxis.maxValue = 4

            scope.chart.data.rows = scope.chartdata.rows

        scope.$watch 'chartdata', render
        scope.$watch 'stacked', render
        scope.$watch 'charttype', render
        scope.$watch 'title', -> scope.chart.options.title = scope.title

    }
