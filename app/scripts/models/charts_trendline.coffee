angular.module('ndApp')
  .factory 'Trendline', ->
    class Trendline
      constructor: ->
        @kind = 'Trendline'

      @deserialize: (data) ->
        chart = new Trendline
        chart.grouping = data.grouping
        chart
