angular.module('ndApp')
  .directive 'ndPopulationPyramid', ($window) ->
    {
      restrict: 'E'

      scope:
        series: '='
        title: '='
        values: '='

      template: '<svg class="nd-chart"></svg>'

      link: (scope, element, attrs) ->
        chart = PopulationPyramid()
        container = d3.select(element[0].children[0])
        container.datum([]).call(chart)

        resize = ->
          width = element.parent().innerWidth()
          chart.height(320).width(width).redraw()

        angular.element($window).on 'resize', resize
        scope.$on "$destroy", -> angular.element($window).off 'resize', resize

        resize()

        tooltipFor = (data) =>
          if scope.values == 'percentage'
            "#{(data.value * 100).toFixed(2)}% (#{data.count} of #{data.total} events)"
          else
            "#{data.value} events"

        updateChart = (series, title) =>
          data = []
          for serie in series
            data.push
              age: serie.age,
              male: serie.male.value,
              female: serie.female.value
          chart.redraw(data)

        scope.$watchCollection('series', () ->
          if scope.series
            updateChart(scope.series, scope.title)
        )
    }
