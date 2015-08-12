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
      q = $q.defer()
      csv = $scope.chart.getCSV($scope.report, $scope.series, q.resolve)
      if Array.isArray(csv)
        csv
      else
        q.promise

    $scope.getCSVFilename = ->
      date = $filter("date")(new Date(), "yyyyMMddHMMss")
      "#{$scope.report.name}_#{$scope.chart.kind}_#{date}".replace(/[^a-zA-Z0-9_]/g, "_")

    queryAll = (queries, callback) ->
      $q.all _.map(queries, (query) -> Cdx.events(query))
        .then (datas) -> callback(_.map(datas, (d) -> d.data))

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

        queryAll queries, (datas) ->
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
