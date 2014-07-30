'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Main page controller
###

angular.module('ndApp')
  .controller 'MainCtrl', ($scope, $http, $log, $routeParams, ReportsService) ->
    $scope.reports = ReportsService.reports()

    $scope.data = {
      series: []
    }

    $scope.doQuery = () ->
      query = JSON.parse($scope.currentReport.query)
      for filter in $scope.currentReport.filters
        filter.applyTo(query)

      $http.post("/cdx/v1/events", query).success (data) ->
        $log.debug("Received #{data}")
        $scope.data.series = data

    if $routeParams.reportId
      $scope.currentReport = ReportsService.findById($routeParams.reportId)
      if $scope.currentReport
        $scope.doQuery()
