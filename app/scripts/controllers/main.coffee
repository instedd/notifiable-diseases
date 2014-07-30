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

    $scope.deleteReport = ->
      index = _.indexOf $scope.reports, $scope.currentReport
      $scope.reports.splice(index, 1)
      if $scope.reports.length == 0
        $location.path "/reports/new"
      else
        $location.path "/reports/#{$scope.reports[0].id}"

    if $routeParams.reportId
      $scope.currentReport = ReportsService.findById($routeParams.reportId)
      if $scope.currentReport
        $scope.$watch 'currentReport', onChange, true
    else if $scope.reports.length > 0
      $location.path "/reports/#{$scope.reports[0].id}"

