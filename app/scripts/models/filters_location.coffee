@Filters ?= {}

class @Filters.LocationFilter
  constructor: (field) ->
    @name = field.name
    @field = () -> field

  label: ->
    @field().label

  type: ->
    "location"

  applyTo: (query) ->
    if @location
      query[@name] = @location.id

  empty: ->
    if @location
      @location.id.toString().length == 0
    else
      true

  allSelected: ->
    false

  selectedDescription: ->
    if @empty()
      "All"
    else
      @field().getFullLocationPath(@location)

  adminLevel: ->
    @location && @location.level

  selectedId: ->
    @location && @location.id

  shortDescription: ->
    @selectedDescription()

  toJSON: ->
    name: @name
    location: @location

  initializeFrom: (data) ->
    @location = if typeof data.location is 'string' or typeof data.location is 'number'
      @field().getLocation(data.location)
    else
      data.location
    return @
