'use strict'

angular.module('ndApp')
  .controller 'ChartsCtrl', ($scope, ChartsService, settings) ->
    $scope.addNewChartIsCollapsed = true

    $scope.toggleAddNewChart = ->
      $scope.addNewChartIsCollapsed = !$scope.addNewChartIsCollapsed

    $scope.showChart = (chart_name) ->
      return false unless $scope.currentReport
      fieldsCollection = $scope.currentReport.fieldsCollection()
      switch chart_name
        when 'Map' then settings.enableMapChart && fieldsCollection.allLocation().length > 0
        when 'Trendline' then true
        when 'PopulationPyramid' then fieldsCollection.age_field() && fieldsCollection.gender_field()
        else throw new "Unknown chart type #{chart_name}"

    $scope.addChart = (kind) ->
      chart = ChartsService.create kind, $scope.currentReport.resource, $scope.currentReport.fieldsCollection()
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

