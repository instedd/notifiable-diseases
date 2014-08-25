angular.module('ndApp')
  .factory 'EnumFilter', (FieldsService, StringService) ->
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

      empty: ->
        @values.length == 0

      selectedDescription: ->
        if @values.length == 0
          "none"
        else if @values.length == FieldsService.valuesFor(@name).length
          "all"
        else if @values.length == 1
          FieldsService.optionLabelFor(@name, @values[0])
        else
          "#{@values.length} selected"

      shortDescription: ->
        labels = _.map(@values, (value) => "\"#{FieldsService.optionLabelFor(@name, value)}\"")
        StringService.toSentence(labels, ", ", " or ")

      @deserialize: (data) ->
        filter = new EnumFilter(data.name)
        filter.values = data.values
        filter
