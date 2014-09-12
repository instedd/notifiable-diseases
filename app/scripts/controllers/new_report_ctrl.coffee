angular.module('ndApp')
  .controller 'NewReportCtrl', ($scope, $location, ReportsService, FieldsService, Cdx) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      FieldsService.loadForContext().then (fieldsCollection) ->
        $scope.reportsDescriptions = reportsDescriptions
        $scope.currentReport = null
        $scope.assays = fieldsCollection.optionsFor("assay_name")
        $scope.report = new Report(fieldsCollection)
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
