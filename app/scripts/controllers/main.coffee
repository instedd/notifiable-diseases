'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Main page controller
###

angular.module('ndApp')
  .controller 'MainCtrl', ($scope, $http, $location, $log, $routeParams, ReportsService, FieldsService) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      $scope.enumFields = FieldsService.allEnum()
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

      $scope.duplicateReport = ->
        dupReport = $scope.currentReport.duplicate()
        ReportsService.create(dupReport).then ->
          $location.path "/reports/#{dupReport.id}"

      $scope.deleteReport = ->
        if confirm("Are you sure you want to delete the report '#{$scope.currentReport.name}'")
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

