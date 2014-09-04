'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Main page controller
###

angular.module('ndApp')
  .controller 'MainCtrl', ($scope, $http, $location, $log, $routeParams, debounce, ReportsService, FieldsService) ->
    $scope.dontSaveReport = {value: false}

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

          # CODEREVIEW: field service should return an object with all the field information, that can answer all, allEnum, datePeriods, etc, and that is stored in $scope so the fieldService is stateless; or play with injector to inject a field with state below a certain point in the tree instead of keeping it in the scope

          $scope.fields = FieldsService.all()
          $scope.enumFields = _.sortBy FieldsService.allEnum(), (f) -> f.label.toLowerCase()
          $scope.datePeriods = FieldsService.datePeriods()

          firstSaveCurrentReport = true
          saveCurrentReport = (newValue, oldValue) ->
            if $scope.dontSaveReport.value
              $scope.dontSaveReport.value = false
              return

            if $scope.currentReport
              unless firstSaveCurrentReport
                # CODEREVIEW: Consider having a model with the actual report data (body), and Report contains the metadata (version) and the actual data (body) as well; watch is issued only on the body
                if newValue.version == oldValue.version
                  ReportsService.save($scope.currentReport)
              firstSaveCurrentReport = false

          $scope.$watch 'currentReport', debounce(saveCurrentReport, 300), true

          # CODEREVIEW: Move the following functions outside the field service init callback

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
