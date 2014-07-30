'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Main page controller
###

angular.module('ndApp')
  .controller 'MainCtrl', ($scope, $http, $location, $log, $routeParams, ReportsService) ->
    $scope.reports = ReportsService.reports()

    if $scope.reports.length == 0
      $location.path "/reports/new"
      return

    $scope.data = {
      series: []
    }

    onChange = ->
      ReportsService.save()
      if $scope.currentReport
        $scope.doQuery()

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
        $scope.$watch 'currentReport', onChange, true
    else if $scope.reports.length > 0
      $location.path "/reports/#{$scope.reports[0].id}"

