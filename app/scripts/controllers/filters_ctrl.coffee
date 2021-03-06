'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope, $q, $timeout, FiltersService, Cdx) ->
    $scope.addNewFilterIsCollapsed = true
    $scope.counts = []
    $scope.expandedFilter = null

    $scope.filterIsExpanded = (filter) ->
      $scope.expandedFilter == filter

    $scope.toggleAddNewFilter = ->
      $scope.addNewFilterIsCollapsed = !$scope.addNewFilterIsCollapsed

    $scope.addFilter = (field) ->
      filter = _.find $scope.currentReport.filters, (filter) -> filter.name == field.name
      unless filter
        filter = FiltersService.create field
        $scope.currentReport.addFilter filter

      # Without this timeout the collapse panel breaks (see #7134)
      $timeout ->
        $scope.expandedFilter = filter

      $scope.toggleAddNewFilter()

    $scope.removeFilterByIndex = (index) ->
      $scope.currentReport.filters.splice(index, 1)

    $scope.filterTemplateFor = (filter) ->
      "views/filters/#{filter.type()}.html"

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

        unless angular.equals(newFilter, oldFilter)
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
