'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope, FiltersService) ->
    $scope.addNewFilterIsCollapsed = true

    $scope.toggleAddNewFilter = ->
      $scope.addNewFilterIsCollapsed = !$scope.addNewFilterIsCollapsed

    $scope.addFilter = (filter) ->
      $scope.currentReport.filters.push filter
      $scope.toggleAddNewFilter()

    $scope.addDateFilter = ->
      filter = FiltersService.create "DateFilter"
      filter.description = "Event date"
      filter.since = "2014-01-01"
      filter.until = "2014-06-01"
      $scope.addFilter filter

    $scope.filterTemplateFor = (filter) ->
      "#{filter.kind}Template"

    $scope.removeFilterByIndex = (index) ->
      $scope.currentReport.filters.splice(index, 1)

    $scope.clearFilters = ->
      $scope.currentReport.filters.splice(0, $scope.currentReport.filters.length)

  .controller 'DateFilterCtrl', ($scope) ->
    1

