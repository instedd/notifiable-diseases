angular.module('ndApp')
  .factory 'Report', (FiltersService, FieldsService, ChartsService, AssaysService) ->
    class Report
      constructor: ->
        @filters = []
        @charts  = []

      createFilter: (name) ->
        filter = FiltersService.create name
        filter.setReport?(this)
        @filters.push filter
        filter

      applyFiltersTo: (query) ->
        for filter in @filters
          filter.applyTo(query)
        query

      newQuery: ->
        page_size: 0
        condition: @assay

      closeQuery: (query) ->
        # If there's no result specified, restrict result to the valid values
        query.result ?= AssaysService.valuesFor(@assay)

      fieldOptionsFor: (fieldName) ->
        type = FieldsService.typeFor(fieldName)
        if type == 'result'
          AssaysService.optionsFor(@assay)
        else
          FieldsService.optionsFor(fieldName)

      duplicate: ->
        dup = new Report
        dup.name = "#{@name} (duplicate)"
        dup.description = @description
        dup.assay = @assay
        dup.filters = @filters
        dup.charts = @charts
        dup

      @deserialize: (data) ->
        report = new Report
        report.id = data.id
        report.name = data.name
        report.description = data.description
        report.assay = data.assay
        report.filters = _.map data.filters, (filter) ->
          FiltersService.deserialize(filter)
        report.charts = _.map data.charts, (chart) ->
          ChartsService.deserialize(chart)
        report

