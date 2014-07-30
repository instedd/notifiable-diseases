class @DateFilter
  constructor: ->
    @kind = "Date"

  applyTo: (query) ->
    query.since = @since
    query.until = @until
