@Filters ?= {}

class @Filters.DateFilter
  constructor: (field) ->
    @name = field.name
    @since = moment().subtract(30, 'days').format('YYYY-MM-DD')
    @until = moment().format('YYYY-MM-DD')

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
