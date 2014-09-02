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

      allSelected: ->
        @values.length == FieldsService.valuesFor(@name).length

      selectedDescription: ->
        if @values.length == 0
          "none"
        else if @values.length == FieldsService.valuesFor(@name).length
          "all"
        else if @values.length == 1
          FieldsService.optionLabelFor(@name, @values[0])
        else
          "#{@values.length} selected"

      shortDescription: (first) ->
        if @values.length == 0
          label = FieldsService.labelFor(@name).toLowerCase()
          if first
            "No #{label}"
          else
            "no #{label}"
        else
          labels = _.map(@values, (value) => "\"#{FieldsService.optionLabelFor(@name, value)}\"")
          if labels.length == 3
            if labels[2].length <= "1 other".length
              "#{labels[0]}, #{labels[1]} or #{labels[2]}"
            else
              "#{labels[0]}, #{labels[1]} and 1 other"
          else if labels.length > 3
            "#{labels[0]}, #{labels[1]} and #{labels.length - 2} others"
          else
            StringService.toSentence(labels, ", ", " or ")

      @deserialize: (data) ->
        filter = new EnumFilter(data.name)
        filter.values = data.values
        filter
