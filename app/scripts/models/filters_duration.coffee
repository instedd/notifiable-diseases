@Filters ?= {}

class @Filters.DurationFilter
  constructor: (field) ->
    @name = field.name
    @minimum = field.minimum
    @maximum = field.maximum
    @field = () -> field

  type: ->
    "duration"

  label: ->
    @field().label

  applyTo: (query) ->
    value = ""
    if @minimum != null
      value += "#{@minimum}yo"
    value += ".."
    if @maximum != null
      value += "#{@maximum}yo"
    query[@name] = value

  empty: ->
    false

  allSelected: ->
    false

  selectedDescription: ->
    if @minimum == null
      if @maximum == null
        "all"
      else
        "≤ #{@maximum} years old"
    else
      if @maximum == null
        "≥ #{@minimum} years old"
      else
        "#{@minimum} to #{@maximum} years old"

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
