'use strict'

angular.module('ndApp')
  .controller 'ChartsCtrl', ($scope, ChartsService) ->
    $scope.addNewChartIsCollapsed = true

    $scope.toggleAddNewChart = ->
      $scope.addNewChartIsCollapsed = !$scope.addNewChartIsCollapsed

    $scope.addChart = (kind) ->
      chart = ChartsService.create kind
      chart.initializeNew?()
      $scope.currentReport.charts.push chart
      $scope.toggleAddNewChart()

    $scope.removeChartByIndex = (index) ->
      $scope.currentReport.charts.splice(index, 1)

    $scope.chartTemplateFor = (chart) ->
      "views/charts/#{chart.kind}.html"

    $scope.chartConfigTemplateFor = (chart) ->
      "views/charts/#{chart.kind}Config.html"

    $scope.hasData = ->
      query = $scope.currentReport.newQuery()
      $scope.currentReport.applyFiltersTo(query)
      $scope.currentReport.closeQuery(query)

      !query.empty

