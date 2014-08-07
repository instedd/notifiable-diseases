angular.module('ndApp')
  .factory 'DateFilter', (FieldsService) ->
    class DateFilter
      constructor: (@name) ->
        @since = "2014-01-01"
        @until = "2014-06-01"

      label: ->
        FieldsService.labelFor(@name)

      applyTo: (query) ->
        query.since = @since
        query.until = @until

      equals: (other) ->
        @since == other.since && @until == other.until

      @deserialize: (data) ->
        filter = new DateFilter(data.name)
        filter.since = data.since
        filter.until = data.until
        filter
