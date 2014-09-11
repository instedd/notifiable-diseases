angular.module('ndApp')
  .directive 'ndPopulationPyramid', () ->
    {
      restrict: 'E'
      scope:
        series: '='
        title: '='
      template: '<div google-chart chart="chart" class="nd-chart"></div>'
      link: (scope, element, attrs) ->
        scope.chart =
          type: "BarChart"
          data:
            cols: [
              {id: "age", label: "Age", type: "string"},
              {id: "male", label: "Male", type: "number"},
              {id: "female", label: "Female", type: "number"},
            ]
            rows: []
          options:
            width: 540
            height: 320
            title: scope.title
            isStacked: true
            colors: ['#DC3912', '#3366cc']
            legend:
              position: 'bottom'
              alignment: 'center'
            hAxis:
              format: '#,###;#,###'
            vAxis:
              direction: -1
            animation:
              duration: 600
              easing: 'out'

        updateChart = (chart, series, title) =>
          rows = []
          for serie in series
            rows.push c: [
                          {v: serie.age},
                          {v: -serie.male, f: "#{serie.male} events"},
                          {v: serie.female, f: "#{serie.female} events"},
                        ]

          chart.data.rows = rows

        scope.$watchCollection('series', () ->
          if scope.series
            updateChart(scope.chart, scope.series, scope.title)
        )
    }
