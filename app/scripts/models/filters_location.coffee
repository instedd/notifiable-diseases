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
      location = @field().locations[@location.id]
      @field().getFullLocationPath(location)

  adminLevel: ->
    @location && @location.level

  shortDescription: ->
    @selectedDescription()

  toJSON: ->
    {
      name: @name
      location: @location.id
    }

  initializeFrom: (data) ->
    @location = @field().locations[data.location]
    @
