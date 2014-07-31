angular.module('ndApp')
  .factory 'Trendline', (Cdx) ->
    class Trendline
      constructor: ->
        @kind = 'Trendline'
        @grouping = 'year'

      getQuery: ->
        group_by: "#{@grouping}(created_at)"

      @deserialize: (data) ->
        chart = new Trendline
        chart.grouping = data.grouping
        chart
