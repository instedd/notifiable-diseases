angular.module('ndApp')
  .factory 'LocationFilter', (FieldsService) ->
    class LocationFilter
      constructor: (@name) ->
        1

      applyTo: (query) ->
        1

      equals: (other) ->
        @location_id == other.location_id

      empty: ->
        @location_id.toString().length == 0

      selectedDescription: ->
        ""

      @deserialize: (data) ->
        filter = new LocationFilter(data.name)
        filter.location_id = data.location_id
        filter
