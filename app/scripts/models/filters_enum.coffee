angular.module('ndApp')
  .factory 'EnumFilter', (FieldsService) ->
    class EnumFilter
      constructor: (@name) ->
        @values = FieldsService.valuesFor(@name)

      options: ->
        FieldsService.optionsFor(@name)

      applyTo: (query) ->
        query[@name] = @values

        if @values.length == 0
          query.empty = true

      equals: (other) ->
        angular.equals(@values, other.values)

      selectedDescription: (report) ->
        if @values.length == 0
          "none"
        else if @values.length == FieldsService.valuesFor(@name).length
          "all"
        else if @values.length == 1
          FieldsService.optionLabelFor(@name, @values[0])
        else
          "#{@values.length} selected"

      @deserialize: (data) ->
        filter = new EnumFilter(data.name)
        filter.values = data.values
        filter
