'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope, $q, Cdx, FiltersService) ->
    $scope.addNewFilterIsCollapsed = true
    $scope.counts = []

    $scope.toggleAddNewFilter = ->
      $scope.addNewFilterIsCollapsed = !$scope.addNewFilterIsCollapsed

    $scope.addFilter = (kind) ->
      filter = FiltersService.create kind
      $scope.currentReport.filters.push filter
      $scope.toggleAddNewFilter()

    $scope.removeFilterByIndex = (index) ->
      $scope.currentReport.filters.splice(index, 1)

    $scope.filterTemplateFor = (filter) ->
      "views/filters/#{filter.kind}.html"

    $scope.clearFilters = ->
      $scope.currentReport.filters.splice(0, $scope.currentReport.filters.length)

    $scope.hasCount = (index) ->
      $scope.counts[index]?

    firstChange = true
    $scope.$watch 'currentReport.filters', ((newFilters, oldFilters) ->
      if $scope.currentReport
        if firstChange
          index = -1
          firstChange = false
        else
          index = findLeastFilterIndexThatChanged(newFilters, oldFilters)

        for i in [index ... $scope.counts.length]
          $scope.counts[i] = undefined

        for i in [index ... $scope.currentReport.filters.length]
          updateCount i
      ), true

    findLeastFilterIndexThatChanged = (newFilters, oldFilters) ->
      if newFilters.length > oldFilters.length
        return oldFilters.length
      else if newFilters.length < oldFilters.length
        # We could do something better here, but for now this is ok
        return 0

      for i in [0 ... oldFilters.length]
        oldFilter = oldFilters[i]
        newFilter = newFilters[i]
        unless angular.equals(oldFilter, newFilter)
          return i

      $scope.currentReport.filters.length

    updateCount = (index, query) ->
      query = page_size: 0
      i = 0
      while i <= index
        filter = $scope.currentReport.filters[i]
        filter.applyTo query
        i += 1

      Cdx.events(query).success (data) ->
        $scope.counts[index] = data.total_count
