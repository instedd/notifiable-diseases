angular.module('ndApp')
  .directive 'ndPopulationPyramid', () ->
    {
      restrict: 'E'

      scope:
        series: '='
        title: '='
        values: '='

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
            width: '100%'
            height: 320
            title: scope.title
            isStacked: true
            colors: ['#DC3912', '#3366cc']
            legend:
              position: 'bottom'
              alignment: 'center'
            hAxis:
              format: (if scope.values == 'percentage' then '##.##%' else '#,###;#,###')
            vAxis:
              direction: -1
            animation:
              duration: 600
              easing: 'out'

        tooltipFor = (data) =>
          if scope.values == 'percentage'
            "#{data.value * 100}% (#{data.count} of #{data.total} events)"
          else
            "#{data.value} events"

        updateChart = (chart, series, title, isPercentage) =>
          rows = []
          for serie in series
            rows.push c: [
                          {v: serie.age},
                          {v: -serie.male.value,  f: tooltipFor(serie.male)},
                          {v: serie.female.value, f: tooltipFor(serie.female)},
                        ]

          chart.data.rows = rows
          chart.options.hAxis.format = (if scope.values == 'percentage' then '##.##%' else '#,###;#,###')

        scope.$watchCollection('series', () ->
          if scope.series
            updateChart(scope.chart, scope.series, scope.title)
        )
    }
