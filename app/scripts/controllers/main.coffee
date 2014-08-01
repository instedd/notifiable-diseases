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
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      $scope.reportsDescriptions = reportsDescriptions

      if $scope.reportsDescriptions.length == 0
        $location.path "/reports/new"
        return

      firstSaveCurrentReport = true
      saveCurrentReport = (newValue, oldValue) ->
        if $scope.currentReport
          unless firstSaveCurrentReport
            if newValue.version == oldValue.version
              ReportsService.save($scope.currentReport)
          firstSaveCurrentReport = false

      $scope.deleteReport = ->
        ReportsService.delete($scope.currentReport).then (descs) ->
          if descs.length == 0
            $location.path "/reports/new"
          else
            $location.path "/reports/#{descs[0].id}"

      if $routeParams.reportId
        ReportsService.findById($routeParams.reportId).then (report) ->
          $scope.currentReport = report
          $scope.$watch 'currentReport', saveCurrentReport, true
      else if $scope.reportsDescriptions.length > 0
        $location.path "/reports/#{$scope.reportsDescriptions[0].id}"

