'use strict'

angular.module('ndApp')
  .controller 'ChartCtrl', ($q, $scope, $filter, Cdx) ->
    $scope.editingChart = false
    
    $scope.fetchingData = false
    $scope.renderingChart = false

    $scope.loadingChart = -> $scope.fetchingData || $scope.renderingChart

    $scope.edit = ->
      $scope.editingChart = true

    $scope.saveChanges = ->
      $scope.editingChart = false
      render()

    $scope.getCSV = ->
      $scope.chart.getCSV($scope.report, $scope.series)

    $scope.getCSVFilename = ->
      date = $filter("date")(new Date(), "yyyyMMddHMMss")
      "#{$scope.report.name}_#{$scope.chart.kind}_#{date}".replace(/[^a-zA-Z0-9_]/g, "_")

    queryAll = (queries, index, datas, callback) ->
      if index < queries.length
        query = queries[index]
        Cdx.events(query).success (data) ->
          datas.push data
          queryAll(queries, index + 1, datas, callback)
      else
        callback(datas)

    render = ->
      # CODEREVIEW: Consider adding report as a property to query object
      query = $scope.report.newQuery()
      $scope.report.applyFiltersTo query
      queries = $scope.chart.applyToQuery(query, $scope.report.filters)

      for query in queries
        $scope.report.closeQuery(query)

      if _.all(queries, (query) -> query.empty)
        datas = _.map queries, (query) -> {events: [], total_count: 0}

        $scope.series = $scope.chart.getSeries($scope.report, datas)
      else
        # TO-DO: consider making the data update explicit instead
        # of depending on the chart watching the 'series' attribute
        # of the scope.

        startRenderingChart()
        $scope.fetchingData = true

        queryAll queries, 0, [], (datas) ->
          $scope.series = $scope.chart.getSeries($scope.report, datas)
          
          $scope.fetchingData = false

    $scope.$watch 'report.filters', render, true

    # the chart doesn't know this controller.
    # this is currently the way to tell ask the chart
    # to notify us when it has finished rendering new
    # data.
    startRenderingChart = ->
      $scope.renderingChart = true
      $scope.chart.startRendering($q).then ->
        $scope.renderingChart = false