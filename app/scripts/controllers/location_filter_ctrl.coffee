'use strict'

angular.module('ndApp')
  .controller 'LocationFilterCtrl', ($scope) ->
    field = $scope.filter.field()
    flattenedLocations = field.flattenedLocations()

    $scope.selectedLocationId = $scope.filter.location?.id

    locationById = (id) ->
      field.byId[id.toString()]

    matchesQuery = (location, query) ->
      name = location.name.toLowerCase()
      name.length >= query.length && name.substr(0, query.length) == query

    fullPath = (location) ->
      field.getFullLocationPath(location)

    $scope.select2Options =
      minimumInputLength: 1

      query: (query) ->
        term = query.term.toLowerCase()

        results = []
        for location in flattenedLocations
          if matchesQuery(location, term)
            text = fullPath(location)
            results.push id: location.id, text: text, textLower: text.toLowerCase()

        results.sort (x, y) ->
          if x.textLower < y.textLower
            -1
          else if x.textLower > y.textLower
            1
          else
            0

        query.callback(results: results)

      initSelection: (element, callback) ->
        id = $(element).val()

        if id != "" && (location = locationById(id))
          $scope.filter.location = id: location.id, name: location.name, level: location.level
          callback(id: location.id, text: fullPath(location))

