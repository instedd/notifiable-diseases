'use strict'

angular.module('ndApp')
  .controller 'ChartCtrl', ($scope, Cdx) ->
    render = ->
      query = $scope.chart.getQuery()
      $scope.report.applyFiltersTo query

      Cdx.events(query).success (data) ->
        $scope.series = data

    $scope.$watch 'report.filters', render, true
    $scope.$watch 'chart'         , render, true
