angular.module('ndApp')
  .factory 'EnumFilter', (FieldsService) ->
    class EnumFilter
      constructor: (@name) ->
        @values = FieldsService.valuesFor(@name)

      label: ->
        FieldsService.labelFor(@name)

      options: ->
        FieldsService.optionsFor(@name)

      applyTo: (query) ->
        query[@name] = @values

        if @values.length == 0
          query.empty = true

      @deserialize: (data) ->
        filter = new EnumFilter(data.name)
        filter.values = data.values
        filter
