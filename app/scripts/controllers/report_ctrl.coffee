'use strict'

angular.module('ndApp')
  .controller 'ReportCtrl', ($scope, $http, $location, $log, $routeParams, debounce, ReportsService, FieldsService) ->
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

    goToReport = (id) ->
      $location.path "/reports/#{id}"

    goToFirstReport = ->
      goToReport($scope.reportsDescriptions[0].id)

    goToNewReport = ->
      $location.path "/reports/new"

    currentReportVersion = null

    firstSaveCurrentReport = true
    saveCurrentReport = (newValue, oldValue) ->
      unless firstSaveCurrentReport
        ReportsService.save($scope.currentReport, currentReportVersion).then (newVersion) ->
          currentReportVersion = newVersion
      firstSaveCurrentReport = false

    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      $scope.reportsDescriptions = reportsDescriptions

      if $scope.reportsDescriptions.length == 0
        $location.path "/reports/new"
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
          [$scope.currentReport, currentReportVersion] = ReportsService.deserialize(report)
          $scope.fieldsInfo =
            fields: FieldsService.all()
            enumFields: FieldsService.allEnum()
            datePeriods: FieldsService.datePeriods()

          $scope.$watch 'currentReport', debounce(saveCurrentReport, 300), true
