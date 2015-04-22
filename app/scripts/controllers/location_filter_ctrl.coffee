'use strict'

angular.module('ndApp')
  .controller 'LocationFilterCtrl', ($scope, $http) ->
    field = $scope.filter.field()
    $scope.selectedLocationId = $scope.filter.location?.id

    matchesQuery = (location, query) ->
      name = location.name.toLowerCase()
      name.length >= query.length && name.substr(0, query.length) == query

    formatLocation = (location) ->
      id: location.id
      text: field.getFullLocationPath(location)

    resolveLocation = (location, callback) ->
      $scope.filter.location = location #id: location.id, name: location.name, level: location.level, text: field.getFullLocationPath(location)
      callback(id: location.id, text: field.getFullLocationPath(location))


    localOptions = () ->
      minimumInputLength: 1

      query: (query) ->
        term = query.term.toLowerCase()

        results = []
        for id, location of field.locations
          if matchesQuery(location, term)
            text = field.getFullLocationPath(location)
            results.push id: location.id, text: text, textLower: text.toLowerCase()

        results.sort (x, y) ->
          if x.textLower < y.textLower
            -1
          else if x.textLower > y.textLower
            1
          else
            0

        query.callback(results: results)

      initSelection: (element, callback, e ,f) ->
        id = $(element).val()

        if id != "" && (location = field.getLocation(id))
          resolveLocation(location, callback)


    remoteOptions = () ->
      minimumInputLength: 2
      ajax:
        url: field.locations.url + "/suggest"
        dataType: "json"
        quietMillis: 250
        cache: true
        data: (term, page) ->
          name: term
          limit: 20
          offset: (page-1) * 20
          ancestors: true
          set: field.locations.set
        results: (data, page) ->
          more: (data.length == 20)
          results: _.map(data, formatLocation)

      initSelection: (element, callback) ->
        id = $(element).val()
        if id != ""
          field.locations.details(id, {ancestors: true}).success (data) ->
            resolveLocation(data[0], callback)


    $scope.select2Options = if field.remote then remoteOptions() else localOptions()


