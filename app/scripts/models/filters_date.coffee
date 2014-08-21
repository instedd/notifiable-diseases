angular.module('ndApp')
  .factory 'DateFilter', (FieldsService) ->
    class DateFilter
      constructor: (@name) ->
        @since = "2014-01-01"
        @until = "2014-06-01"

      applyTo: (query) ->
        query.since = @since
        query.until = @until

      equals: (other) ->
        @since == other.since && @until == other.until

      empty: ->
        false

      selectedDescription: (report) ->
        "#{@since} to #{@until}"

      @deserialize: (data) ->
        filter = new DateFilter(data.name)
        filter.since = data.since
        filter.until = data.until
        filter
