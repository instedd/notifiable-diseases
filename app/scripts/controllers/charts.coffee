'use strict'

angular.module('ndApp')
  .controller 'ChartsCtrl', ($scope, ChartsService) ->
    $scope.addNewChartIsCollapsed = true

    $scope.toggleAddNewChart = ->
      $scope.addNewChartIsCollapsed = !$scope.addNewChartIsCollapsed

    $scope.addChart = (chart) ->
      $scope.currentReport.charts.push chart
      $scope.toggleAddNewChart()

    $scope.addTrendline = ->
      chart = ChartsService.create "Trendline"
      chart.grouping = "year"
      $scope.addChart chart

    $scope.chartTemplateFor = (chart) ->
      "#{chart.kind}Template"
