'use strict'

angular.module('ndApp')
  .controller 'ChartsCtrl', ($scope, ChartsService) ->
    $scope.addNewChartIsCollapsed = true

    $scope.toggleAddNewChart = ->
      $scope.addNewChartIsCollapsed = !$scope.addNewChartIsCollapsed

    $scope.addChart = (kind) ->
      chart = ChartsService.create kind
      $scope.currentReport.charts.push chart
      $scope.toggleAddNewChart()

    $scope.chartTemplateFor = (chart) ->
      "views/charts/#{chart.kind}.html"
