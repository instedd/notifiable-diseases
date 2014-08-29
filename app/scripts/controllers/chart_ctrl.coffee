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

    queryAll = (queries, index, datas, callback) ->
      if index < queries.length
        query = queries[index]
        Cdx.events(query).success (data) ->
          datas.push data
          queryAll(queries, index + 1, datas, callback)
      else
        callback(datas)

    render = ->
      return if $scope.editingChart

      query = $scope.report.newQuery()
      $scope.report.applyFiltersTo query
      queries = $scope.chart.applyToQuery(query, $scope.report.filters)

      for query in queries
        $scope.report.closeQuery(query)

      if _.all(queries, (query) -> query.empty)
        datas = _.map queries, (query) -> {events: [], total_count: 0}

        $scope.series = $scope.chart.getSeries($scope.report, datas)
      else
        $scope.loadingChart = true
        queryAll queries, 0, [], (datas) ->
          $scope.series = $scope.chart.getSeries($scope.report, datas)
          $scope.loadingChart = false

    $scope.$watch 'report.filters', render, true
