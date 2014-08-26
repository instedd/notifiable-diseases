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
      $scope.reportsDescriptions = reportsDescriptions

      if $scope.reportsDescriptions.length == 0
        $location.path "/reports/new"
        return

      goToReport = (id) ->
        $location.path "/reports/#{id}"

      goToFirstReport = ->
        goToReport($scope.reportsDescriptions[0].id)

      goToNewReport = ->
        $location.path "/reports/new"

      unless $routeParams.reportId
        goToFirstReport()
        return

      ReportsService.findById($routeParams.reportId).then (report) ->
        unless report
          if $scope.reportsDescriptions.length > 0
            goToFirstReport()
          else
            goToNewReport()
          return

        # This is tricky: to deserialize the report we first need to
        # initialize the FieldsService. But to initialize it we need
        # to know the report's assay. So, we invoke getAssay to get
        # the report's assay *without* deserailizing it to an object.
        # Once we initialize the FieldsService we can safely deserialize
        # the report.
        assay = ReportsService.getAssay(report)

        FieldsService.init(assay_name: assay).then ->
          report = ReportsService.deserialize(report)
          $scope.currentReport = report

          $scope.fields = FieldsService.all()
          $scope.enumFields = _.sortBy FieldsService.allEnum(), (f) -> f.label.toLowerCase()
          $scope.datePeriods = FieldsService.datePeriods()

          firstSaveCurrentReport = true
          saveCurrentReport = (newValue, oldValue) ->
            if $scope.currentReport
              unless firstSaveCurrentReport
                if newValue.version == oldValue.version
                  ReportsService.save($scope.currentReport)
              firstSaveCurrentReport = false

          $scope.$watch 'currentReport', saveCurrentReport, true

          $scope.duplicateReport = ->
            dupReport = $scope.currentReport.duplicate()
            ReportsService.create(dupReport).then ->
              goToReport(dupReport.id)

          $scope.deleteReport = ->
            if confirm("Are you sure you want to delete the report '#{$scope.currentReport.name}'")
              ReportsService.delete($scope.currentReport).then (descs) ->
                if descs.length == 0
                  goToNewReport()
                else
                  goToReport(descs[0].id)
