angular.module('ndApp')
  .factory 'ResultFilter', (FieldsService, AssaysService) ->
    class ResultFilter
      constructor: (@name) ->
        true

      setReport: (report) ->
        @values = AssaysService.valuesFor(report.assay)

      options: (report) ->
        AssaysService.optionsFor(report.assay)

      applyTo: (query) ->
        query[@name] = @values

        if @values.length == 0
          query.empty = true

      equals: (other) ->
        angular.equals(@values, other.values)

      @deserialize: (data) ->
        filter = new ResultFilter(data.name)
        filter.values = data.values
        filter
