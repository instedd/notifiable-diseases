angular.module('ndApp')
  .controller 'NewReportCtrl', ($scope, $location, ReportsService, FieldsService, Cdx, settings) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      FieldsService.loadForContext().then (fieldsCollection) ->
        mainField = fieldsCollection.find(FieldsCollection.fieldNames[settings.reportMainField] || settings.reportMainField)
        throw "Main report field #{settings.reportMainField} should exist and be of kind enum" if not mainField? or not mainField.type == 'enum'

        $scope.reportsDescriptions = reportsDescriptions
        $scope.mainLabel = mainField.label
        $scope.currentReport = null
        $scope.options = mainField.options
        $scope.report = new Report(fieldsCollection)
        $scope.report.mainField = mainField.name
        $scope.report.mainValue = null
        $scope.events = "..."

        computeCount = ->
          return if $scope.report.mainValue == null
          query = $scope.report.newQuery()
          $scope.report.closeQuery(query)

          Cdx.events(query).success (data) ->
            $scope.events = data.total_count

        $scope.$watch 'report.mainValue', computeCount

        $scope.createReport = ->
          if $.trim($scope.report.name).length == 0
            return

          ReportsService.create($scope.report).then ->
            $location.path "/reports/#{$scope.report.id}"
