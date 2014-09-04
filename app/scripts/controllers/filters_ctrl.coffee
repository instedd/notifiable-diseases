'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope, $q, $timeout, Cdx, FieldsService) ->
    $scope.addNewFilterIsCollapsed = true
    $scope.counts = []
    $scope.expandedFilter = null

    $scope.filterIsExpanded = (filter) ->
      $scope.expandedFilter == filter

    $scope.toggleAddNewFilter = ->
      $scope.addNewFilterIsCollapsed = !$scope.addNewFilterIsCollapsed

    $scope.addFilter = (name) ->
      filter = _.find $scope.currentReport.filters, (filter) -> filter.name == name
      unless filter
        filter = $scope.currentReport.createFilter name

      # Without this timeout the collapse panel breaks (see #7134)
      $timeout ->
        $scope.expandedFilter = filter

      $scope.toggleAddNewFilter()

    $scope.removeFilterByIndex = (index) ->
      $scope.currentReport.filters.splice(index, 1)

    $scope.filterTemplateFor = (filter) ->
      "views/filters/#{FieldsService.typeFor(filter.name)}.html"

    $scope.toggleFilter = (filter) ->
      if $scope.expandedFilter == filter
        $scope.expandedFilter = null
      else
        $scope.expandedFilter = filter

    $scope.clearFilters = ->
      $scope.currentReport.filters.splice(0, $scope.currentReport.filters.length)

    $scope.hasCount = (index) ->
      $scope.counts[index]?

    $scope.isLastFilter = ($index) ->
      $scope.currentReport.filters.length == $index + 1

    $scope.labelFor = (filter) ->
      FieldsService.labelFor(filter.name)

    $scope.instructionsFor = (filter) ->
      FieldsService.instructionsFor(filter.name)

    firstChange = true
    $scope.$watch 'currentReport.filters', ((newFilters, oldFilters) ->
      if $scope.currentReport
        if firstChange
          index = -1
          firstChange = false
        else
          index = findLeastFilterIndexThatChanged(newFilters, oldFilters)

        for i in [index ... $scope.counts.length]
          $scope.counts[i] = null

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

        # CODEREVIEW: Use == instead of equals after view props are moved outside the filter itself
        unless newFilter.equals(oldFilter)
          return i

      $scope.currentReport.filters.length

    updateCount = (index, query) ->
      query = $scope.currentReport.newQuery()

      i = 0
      while i <= index
        filter = $scope.currentReport.filters[i]
        filter.applyTo query

        if query.empty
          $scope.counts[index] = 0
          return

        i += 1

      $scope.currentReport.closeQuery(query)

      Cdx.events(query).success (data) ->
        $scope.counts[index] = data.total_count
