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

    $scope.validateReportName = (name) ->
      length = $.trim(name).length
      if length == 0
        return "Name can't be blank"
      else if length > 60
        return "Name is too long (maximum 60 chars, current is #{length})"

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

      ReportsService.findById($routeParams.reportId).then (reportData) ->
        unless reportData
          if $scope.reportsDescriptions.length > 0
            goToFirstReport()
          else
            goToNewReport()
          return

        context = ReportsService.getContext(reportData)

        FieldsService.loadForContext(context).then (fieldsCollection) ->
          [$scope.currentReport, currentReportVersion] = ReportsService.deserialize(reportData, fieldsCollection)
          $scope.fieldsInfo =
            fields: fieldsCollection.all()
            filterFields: fieldsCollection.filterFields()
            enumFields: fieldsCollection.allEnum()
            multiValuedEnumFields: fieldsCollection.multiValuedEnums()
            datePeriods: fieldsCollection.datePeriods()

          $scope.$watch 'currentReport', debounce(saveCurrentReport, 300), true

        FieldsService.loadForContext().then (fieldsCollection) ->
          mainField = fieldsCollection.fields[$scope.currentReport.mainField]
          $scope.assay = mainField.labelFor($scope.currentReport.mainValue)


