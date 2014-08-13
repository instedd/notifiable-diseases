angular.module('ndApp')
  .controller 'ReportsCtrl', ($scope, $location, Report, ReportsService, AssaysService, Cdx) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      $scope.reportsDescriptions = reportsDescriptions
      $scope.currentReport = null
      $scope.assays = AssaysService.all()
      $scope.report = new Report
      $scope.report.assay = $scope.assays[0].name
      $scope.events = "..."

      computeCount = ->
        query = $scope.report.newQuery()
        $scope.report.closeQuery(query)

        Cdx.events(query).success (data) ->
          $scope.events = data.total_count

      $scope.$watch 'report.assay', computeCount

      $scope.createReport = ->
        if $.trim($scope.report.name).length == 0
          return

        ReportsService.create($scope.report).then ->
          $location.path "/reports/#{$scope.report.id}"
