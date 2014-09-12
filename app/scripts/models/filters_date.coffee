@Filters ?= {}

class @Filters.DateFilter
  constructor: (field) ->
    @name = field.name
    @since = "2014-01-01"
    @until = "2014-06-01"
    @field = () -> field

  label: ->
    @field().label

  type: ->
    "date"

  dateResolution: ->
    @field().dateResolution()

  applyTo: (query) ->
    query.since = @since
    query.until = @until

  empty: ->
    false

  allSelected: ->
    false

  selectedDescription: ->
    "#{@since} to #{@until}"

  toJSON: ->
    {
      name: @name
      since: @since
      until: @until
    }

  initializeFrom: (data) ->
    @since = data.since
    @until = data.until
    @
