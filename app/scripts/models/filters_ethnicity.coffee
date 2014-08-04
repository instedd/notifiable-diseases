angular.module('ndApp')
  .factory 'EthnicityFilter', (FieldsService) ->
    class EthnicityFilter
      constructor: ->
        @kind = 'EthnicityFilter'
        @description = "Ethnicity"
        @values = []

      options: ->
        FieldsService.optionsFor("ethnicity")

      applyTo: (query) ->
        query.ethnicity = @values

        if @values.length == 0
          query.empty = true

      @deserialize: (data) ->
        filter = new EthnicityFilter
        filter.values = data.values
        filter
