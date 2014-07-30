angular.module('ndApp')
  .controller 'ReportsCtrl', ($scope, $location, Report, ReportsService) ->
    $scope.reports = ReportsService.reports()
    $scope.currentReport = null

    $scope.createReport = ->
      if $.trim($scope.name).length == 0
        return

      report = new Report($scope.name, $scope.description)
      ReportsService.create report, ->
        $location.path "/reports/#{report.id}"
