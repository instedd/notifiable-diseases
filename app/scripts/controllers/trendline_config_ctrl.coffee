'use strict'

angular.module('ndApp').controller 'TrendlineConfigCtrl', ($scope, FieldsService) ->
  getLocationFilter = ->
    _.find $scope.currentReport.filters, (filter) -> filter.name == "location"

  $scope.hasParentLocations = ->
    $scope.parentLocations().length > 0

  $scope.parentLocations = ->
    locationFilter = getLocationFilter()
    if locationId = locationFilter?.location?.id
      parentLocations = FieldsService.getParentLocations("location", locationId)

      # Initialize $scope.chart.compareToLocation if not already set, so the
      # combo-box isn't selected with an empty option
      if parentLocations.length > 0 && !$scope.chart.compareToLocation
        $scope.chart.compareToLocation = parentLocations[0].level

      parentLocations
    else
      []
