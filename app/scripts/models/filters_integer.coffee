@Filters ?= {}

class @Filters.IntegerFilter
  constructor: (field) ->
    @name = field.name
    @minimum = field.minimum
    @maximum = field.maximum
    @field = () -> field

  type: ->
    "integer"

  label: ->
    @field().label

  applyTo: (query) ->
    query["min_#{@name}"] = @minimum
    query["max_#{@name}"] = @maximum

  empty: ->
    false

  allSelected: ->
    false

  selectedDescription: ->
    "#{@minimum} to #{@maximum}"

  shortDescription: ->
    @selectedDescription()

  toJSON: ->
    {
      name: @name
      minimum: @minimum
      maximum: @maximum
    }

  initializeFrom: (data) ->
    @minimum= data.minimum
    @maximum= data.maximum
    @
