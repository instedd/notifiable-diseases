angular.module('ndApp')
  .factory 'GenderFilter', (FieldsService) ->
    class GenderFilter
      constructor: ->
        @kind = 'GenderFilter'
        @description = "Gender"
        @values = []

      options: ->
        FieldsService.optionsFor("gender")

      applyTo: (query) ->
        query.gender = @values

        if @values.length == 0
          query.empty = true

      @deserialize: (data) ->
        filter = new GenderFilter
        filter.values = data.values
        filter
