angular.module('ndApp')
  .factory 'Report', (FiltersService) ->
    class Report
      constructor: (@name, @description) ->
        @filters = []
        @query = '{"group_by": "year(created_at)"}'

      @deserialize: (data) ->
        report = new Report(data.name, data.description)
        report.id = data.id
        report.query = data.query
        report.filters = _.map data.filters, (filter) ->
          FiltersService.deserialize(filter)
        report

