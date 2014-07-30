angular.module('ndApp')
  .factory 'DateFilter', ->
    class DateFilter
      constructor: ->
        @kind = 'DateFilter'

      applyTo: (query) ->
        query.since = @since
        query.until = @until

      @deserialize: (data) ->
        filter = new DateFilter
        filter.description = data.description
        filter.since = data.since
        filter.until = data.until
        filter
