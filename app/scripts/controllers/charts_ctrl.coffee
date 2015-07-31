'use strict'

angular.module('ndApp')
  .controller 'ChartsCtrl', ($scope, ChartsService, settings) ->
    $scope.addNewChartIsCollapsed = true

    $scope.toggleAddNewChart = ->
      $scope.addNewChartIsCollapsed = !$scope.addNewChartIsCollapsed

    $scope.showChart = (chart_name) ->
      chart_name != 'Map' || settings.enableMapChart

    $scope.addChart = (kind) ->
      chart = ChartsService.create kind, $scope.currentReport.fieldsCollection()
      $scope.currentReport.addChart chart
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

