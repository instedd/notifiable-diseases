'use strict'

angular.module('ndApp')
  .controller 'ChartCtrl', ($scope, $filter, Cdx) ->
    $scope.editingChart = false
    $scope.loadingChart = false

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

      query = $scope.report.newQuery()
      $scope.report.applyFiltersTo query
      $scope.chart.applyToQuery(query, $scope.report.filters)
      $scope.report.closeQuery(query)

      if query.empty
        $scope.series = $scope.chart.getSeries($scope.report, {events: [], total_count: 0})
      else
        $scope.loadingChart = true
        Cdx.events(query).success (data) ->
          $scope.series = $scope.chart.getSeries($scope.report, data)
          $scope.loadingChart = false

    $scope.$watch 'report.filters', render, true
