angular.module('ndApp')
  .controller 'NewReportCtrl', ($scope, $location, Report, ReportsService, FieldsService, Cdx) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      FieldsService.init().then ->
        $scope.reportsDescriptions = reportsDescriptions
        $scope.currentReport = null
        $scope.assays = FieldsService.optionsFor("assay_name")
        $scope.report = new Report
        $scope.report.assay = $scope.assays[0].value
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
