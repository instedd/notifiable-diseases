'use strict'

angular.module('ndApp')
  .controller 'ChartCtrl', ($scope, Cdx) ->
    $scope.editingChart = false

    $scope.edit = ->
      $scope.editingChart = true

    $scope.saveChanges = ->
      $scope.editingChart = false
      render()

    render = ->
      return if $scope.editingChart

      query = $scope.chart.getQuery()
      $scope.report.applyFiltersTo query

      if query.empty
        $scope.series = $scope.chart.getSeries([])
      else
        Cdx.events(query).success (data) ->
          $scope.series = $scope.chart.getSeries(data)

    $scope.$watch 'report.filters', render, true
