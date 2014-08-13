'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope, $q, Cdx, FieldsService) ->
    $scope.addNewFilterIsCollapsed = true
    $scope.counts = []
    $scope.fields = FieldsService.all()

    $scope.toggleAddNewFilter = ->
      $scope.addNewFilterIsCollapsed = !$scope.addNewFilterIsCollapsed

    $scope.addFilter = (name) ->
      filter = _.find $scope.currentReport.filters, (filter) -> filter.name == name
      if filter
        filter.expanded = false
      else
        filter = $scope.currentReport.createFilter name

      $scope.toggleFilter(filter)
      $scope.toggleAddNewFilter()

    $scope.removeFilterByIndex = (index) ->
      $scope.currentReport.filters.splice(index, 1)

    $scope.filterTemplateFor = (filter) ->
      "views/filters/#{FieldsService.typeFor(filter.name)}.html"

    $scope.toggleFilter = (filter) ->
      newExpanded = !filter.expanded
      for otherFilter in $scope.currentReport.filters
        otherFilter.expanded = false
      filter.expanded = newExpanded

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
