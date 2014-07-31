'use strict'

angular.module('ndApp')
  .controller 'ChartCtrl', ($scope, Cdx) ->
    $scope.inConfig = false

    $scope.saveChanges = ->
      $scope.inConfig = false
      render()

    render = ->
      return if $scope.inConfig

      query = $scope.chart.getQuery()
      $scope.report.applyFiltersTo query

      Cdx.events(query).success (data) ->
        $scope.series = data

    $scope.$watch 'report.filters', render, true
