'use strict'

angular.module('ndApp')
  .controller 'ChartCtrl', ($scope, $filter, Cdx) ->
    $scope.editingChart = false

    $scope.edit = ->
      $scope.editingChart = true

    $scope.saveChanges = ->
      $scope.editingChart = false
      render()

    $scope.getCSV = ->
      $scope.chart.getCSV($scope.series)

    $scope.getCSVFilename = ->
      date = $filter("date")(new Date(), "yyyyMMddHMMss")
      "#{$scope.currentReport.name}_#{$scope.chart.kind}_#{date}".replace(/[^a-zA-Z0-9_]/g, "_")

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
