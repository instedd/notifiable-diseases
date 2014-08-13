angular.module('ndApp')
  .factory 'ResultFilter', (FieldsService, AssaysService) ->
    class ResultFilter
      constructor: (name) ->
        true

      setReport: (report) ->
        @values = AssaysService.valuesFor(report.assay)

      label: ->
        FieldsService.labelFor('result')

      options: (report) ->
        AssaysService.optionsFor(report.assay)

      applyTo: (query) ->
        query.result = @values

        if @values.length == 0
          query.empty = true

      equals: (other) ->
        angular.equals(@values, other.values)

      @deserialize: (data) ->
        filter = new ResultFilter('result')
        filter.values = data.values
        filter
