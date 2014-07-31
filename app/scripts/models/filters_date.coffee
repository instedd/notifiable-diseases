angular.module('ndApp')
  .factory 'DateFilter', ->
    class DateFilter
      constructor: ->
        @kind = 'DateFilter'
        @description = "Event date"
        @since = "2014-01-01"
        @until = "2014-06-01"

      applyTo: (query) ->
        query.since = @since
        query.until = @until

      @deserialize: (data) ->
        filter = new DateFilter
        filter.description = data.description
        filter.since = data.since
        filter.until = data.until
        filter
