angular.module('ndApp')
  .factory 'Report', (FiltersService) ->
    class Report
      constructor: (@name, @description) ->
        @filters = []

      @deserialize: (data) ->
        report = new Report(data.name, data.description)
        report.id = data.id
        report.filters = _.map data.filters, (filter) ->
          FiltersService.deserialize(filter)
        report

