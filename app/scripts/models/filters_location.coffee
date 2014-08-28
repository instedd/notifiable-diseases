angular.module('ndApp')
  .factory 'LocationFilter', (FieldsService) ->
    class LocationFilter
      constructor: (@name) ->
        1

      applyTo: (query) ->
        if @location
          query["location"] = @location.id

      equals: (other) ->
        _.isEqual(@location, other.location)

      empty: ->
        if @location
          @location.id.toString().length == 0
        else
          true

      selectedDescription: ->
        if @empty()
          "All"
        else
          FieldsService.locationLabelFor(@name, @location.id)

      adminLevel: ->
        @location && @location.level

      shortDescription: ->
        @selectedDescription()

      @deserialize: (data) ->
        filter = new LocationFilter(data.name)
        filter.location = data.location
        filter
