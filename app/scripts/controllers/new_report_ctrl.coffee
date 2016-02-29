angular.module('ndApp')
  .controller 'NewReportCtrl', ($scope, $location, ReportsService, FieldsService, Cdx, settings) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->

      $scope.reportsDescriptions = reportsDescriptions

      $scope.resourceOptions = _.map(settings.resources, (r) -> {value: r, label: _.capitalize(r)})
      $scope.resource = settings.resources[0]

      resourceSelected = ->
        FieldsService.loadForContext($scope.resource).then (fieldsCollection) ->
          mainField = fieldsCollection.find(FieldsService.nameFor($scope.resource, settings.reportMainField) || settings.reportMainField)
          throw "Main report field #{settings.reportMainField} should exist and be of kind enum" if not mainField? or not mainField.type == 'enum'

          $scope.mainLabel = mainField.label
          $scope.currentReport = null
          $scope.options = mainField.options
          $scope.report = new Report(fieldsCollection, $scope.resource)
          $scope.report.mainField = mainField.name
          # $scope.report.mainOption property is not persisted.
          # It is added to set the selected value in a friendly ng-options way
          # and $scope.report.mainValue is in sync with it.
          $scope.report.mainOption = $scope.options[0]
          $scope.events = "..."
          computeCount()

      computeCount = ->
        return if not $scope.report
        query = $scope.report.newQuery()
        $scope.report.closeQuery(query)

        Cdx.events(query).success (data) ->
          $scope.events = data.total_count

      $scope.createReport = ->
        return if $.trim($scope.report.name).length == 0
        ReportsService.create($scope.report).then ->
          $location.path "/reports/#{$scope.report.id}"

      $scope.$watch 'resource', resourceSelected
      $scope.$watch 'report.mainValue', computeCount
      $scope.$watch 'report.mainOption', ->
        if $scope.report
          $scope.report.mainValue = $scope.report.mainOption.value


