angular.module('ndApp')
  .factory 'GenderFilter', ->
    class GenderFilter
      constructor: ->
        @kind = 'GenderFilter'
        @description = "Gender"
        @values = []

      applyTo: (query) ->
        query.gender = @values

      @deserialize: (data) ->
        filter = new GenderFilter
        filter.values = data.values
        filter
