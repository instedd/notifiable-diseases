'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope) ->
    $scope.addNewFilterIsCollapsed = true

    $scope.toggleAddNewFilter = ->
      $scope.addNewFilterIsCollapsed = !$scope.addNewFilterIsCollapsed

    $scope.addFilter = (filter) ->
      $scope.currentReport.filters.push filter
      $scope.toggleAddNewFilter()

    $scope.addDateFilter = ->
      filter = new DateFilter
      filter.description = "Event date"
      filter.since = "2014-01-01"
      filter.until = "2014-06-01"
      $scope.addFilter filter

    $scope.filterTemplateFor = (filter) ->
      "#{filter.kind}FilterTemplate"

    $scope.removeFilterByIndex = (index) ->
      $scope.currentReport.filters.splice(index, 1)

  .controller 'DateFilterCtrl', ($scope) ->
    1

