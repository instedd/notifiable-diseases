'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Main page controller
###

angular.module('ndApp')
  .controller 'MainCtrl', ($scope, $routeParams, ReportsService) ->
    $scope.reports = ReportsService.reports()

    if $routeParams.reportId
      $scope.currentReport = ReportsService.findById($routeParams.reportId)

    $scope.data = {
      series: []
    }
