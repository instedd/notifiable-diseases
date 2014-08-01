angular.module('ndApp')
  .controller 'ReportsCtrl', ($scope, $location, Report, ReportsService) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      $scope.reportsDescriptions = reportsDescriptions
      $scope.currentReport = null

      $scope.createReport = ->
        if $.trim($scope.name).length == 0
          return

        report = new Report($scope.name, $scope.description)
        ReportsService.create(report).then ->
          $location.path "/reports/#{report.id}"
