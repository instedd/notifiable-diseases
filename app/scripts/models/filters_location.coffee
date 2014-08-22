angular.module('ndApp')
  .factory 'LocationFilter', (FieldsService) ->
    class LocationFilter
      constructor: (@name) ->
        1

      applyTo: (query) ->
        1

      equals: (other) ->
        true

      empty: ->
        false

      selectedDescription: ->
        ""

      @deserialize: (data) ->
        filter = new LocationFilter(data.name)
        filter
