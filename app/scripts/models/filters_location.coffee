angular.module('ndApp')
  .factory 'LocationFilter', (FieldsService) ->
    class LocationFilter
      constructor: (@name) ->
        1

      applyTo: (query) ->
        if @location
          query["location"] = @location.id

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
          location = FieldsService.locationFor(@name, @location.id)
          FieldsService.getFullLocationPath(@name, location)

      adminLevel: ->
        @location && @location.level

      shortDescription: ->
        @selectedDescription()

      @deserialize: (data) ->
        filter = new LocationFilter(data.name)
        filter.location = data.location
        filter
