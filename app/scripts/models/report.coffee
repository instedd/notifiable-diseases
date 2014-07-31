angular.module('ndApp')
  .factory 'Report', (FiltersService, ChartsService) ->
    class Report
      constructor: (@name, @description) ->
        @filters = []
        @charts  = []

      @deserialize: (data) ->
        report = new Report(data.name, data.description)
        report.id = data.id
        report.filters = _.map data.filters, (filter) ->
          FiltersService.deserialize(filter)
        report.charts = _.map data.charts, (chart) ->
          ChartsService.deserialize(chart)
        report

