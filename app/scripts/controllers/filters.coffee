'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope, FiltersService) ->
    $scope.filters = FiltersService.filters()
    $scope.addNewFilterIsCollapsed = true

    $scope.toggleAddNewFilter = ->
      $scope.addNewFilterIsCollapsed = !$scope.addNewFilterIsCollapsed

    $scope.addFilter = (filter) ->
      $scope.filters.push filter
      $scope.toggleAddNewFilter()

    $scope.addDateFilter = ->
      $scope.addFilter
        kind: "Date"
        description: "Event date"
        since: "2014-01-01"
        until: "2014-06-01"

    $scope.filterTemplateFor = (filter) ->
      "#{filter.kind}FilterTemplate"

    $scope.removeFilterByIndex = (index) ->
      $scope.filters.splice(index, 1)

  .controller 'DateFilterCtrl', ($scope) ->
    1

