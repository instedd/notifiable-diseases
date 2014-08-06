angular.module('ndApp')
  .factory 'AgeGroupFilter', (FieldsService) ->
    class AgeGroupFilter
      constructor: ->
        @kind = 'AgeGroupFilter'
        @description = "Age group"
        @values = FieldsService.valuesFor("age_group")

      options: ->
        FieldsService.optionsFor("age_group")

      applyTo: (query) ->
        query.age_group = @values

        if @values.length == 0
          query.empty = true

      @deserialize: (data) ->
        filter = new AgeGroupFilter
        filter.values = data.values
        filter
