angular.module('ndApp')
  .factory 'GenderFilter', ->
    class GenderFilter
      constructor: ->
        @kind = 'GenderFilter'
        @description = "Gender"
        @value = "male"

      applyTo: (query) ->
        query.gender = @value.toLowerCase()

      @deserialize: (data) ->
        filter = new GenderFilter
        filter.value = data.value
        filter
