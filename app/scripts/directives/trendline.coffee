angular.module('ndApp')
  .directive 'ndTrendline', ($window) ->
    buildWeekParser = ->
      # FIXME: verify that the week starts on sunday or monday and that it's 0 or 1 based
      parser = d3.time.format('%Y-W%W-%w')
      {
        parse: (d) ->
          parser.parse(d + '-0')
      }

    DATE_PARSERS =
      year: d3.time.format('%Y')
      month: d3.time.format('%Y-%m')
      week: buildWeekParser()
      day: d3.time.format('%Y-%m-%d')

    {
      restrict: 'E'

      scope:
        chartdata: '='
        title: '='
        values: '='
        grouping: '='
        comparison: '='

      template: '<svg class="nd-chart"></svg>'

      link: (scope, element, attrs) ->
        chart = StackChart()
        container = d3.select(element[0].children[0])
        container.call(chart, [], [])

        resize = ->
          width = element.parent().innerWidth()
          chart.height(320).width(width).redraw()

        angular.element($window).on 'resize', resize
        scope.$on "$destroy", -> angular.element($window).off 'resize', resize

        resize()

        scope.$watch 'chartdata', ->
          data = []
          rd = []
          if scope.chartdata
            parser = DATE_PARSERS[scope.grouping]
            cols = scope.chartdata.cols.slice(1)
            for row in scope.chartdata.rows
              item = { date: parser.parse(row.c[0].v) }
              if scope.comparison
                item[cols[0].id] = row.c[1].v
                data.push item

                item = { date: item.date }
                item[cols[0].id] = row.c[2].v
                rd.push item
              else
                for col, i in cols
                  item[col.id] = row.c[i + 1].v
                data.push item

            chart.xValues(scope.grouping).yValues(scope.values).redraw(data, rd)
    }
