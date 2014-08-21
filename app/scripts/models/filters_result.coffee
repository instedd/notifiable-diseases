angular.module('ndApp')
  .factory 'ResultFilter', (FieldsService, AssaysService, StringService) ->
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

      empty: ->
        @values.length == 0

      selectedDescription: (report) ->
        if @values.length == 0
          "none"
        else if @values.length == AssaysService.valuesFor(report.assay).length
          "all"
        else if @values.length == 1
          AssaysService.optionLabelFor(report.assay, @values[0])
        else
          "#{@values.length} selected"

      shortDescription: (report) ->
        labels = _.map(@values, (value) => "\"#{AssaysService.optionLabelFor(report.assay, value)}\"")
        StringService.toSentence(labels, ", ", " or ")

      @deserialize: (data) ->
        filter = new ResultFilter(data.name)
        filter.values = data.values
        filter
