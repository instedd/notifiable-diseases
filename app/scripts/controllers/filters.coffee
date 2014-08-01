'use strict'

angular.module('ndApp')
  .controller 'FiltersCtrl', ($scope, FiltersService) ->
    $scope.addNewFilterIsCollapsed = true

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

