angular.module('ndApp')
  .controller 'ReportsCtrl', ($scope, $location, Report, ReportsService, AssaysService) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      $scope.reportsDescriptions = reportsDescriptions
      $scope.currentReport = null
      $scope.assays = AssaysService.all()
      $scope.assay = $scope.assays[0].name

      $scope.createReport = ->
        if $.trim($scope.name).length == 0
          return

        report = new Report
        report.name = $scope.name
        report.description = $scope.description
        report.assay = $scope.assay
        ReportsService.create(report).then ->
          $location.path "/reports/#{report.id}"
