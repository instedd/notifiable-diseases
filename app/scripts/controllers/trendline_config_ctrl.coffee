'use strict'

angular.module('ndApp').controller 'TrendlineConfigCtrl', ($scope) ->
  getLocationFilter = ->
    _.find $scope.currentReport.filters, (filter) -> filter.name == FieldsCollection.fieldNames.location

  getParentLocations = (filter) ->
    if locationId = filter.location?.id
      $scope.currentReport.fieldsCollection().getParentLocations(filter.name, locationId)
    else
      []

  $scope.hasAnyParentLocations = ->
    _.any getLocationFilters(), (filter) -> getParentLocations(filter).length > 0

  $scope.parentLocations = (fieldName) ->
    filter = _.find getLocationFilters(), name: fieldName
    parentLocations = getParentLocations(filter)

    # Initialize $scope.chart.compareToLocation if not already set, so the
    # combo-box isn't selected with an empty option
    if parentLocations.length > 0 && !$scope.chart.compareToLocation
      $scope.chart.compareToLocation = parentLocations[0].level

    parentLocations

  getLocationFilters = ->
    _.filter $scope.currentReport.filters, (filter) -> filter.type() == 'location'

  $scope.comparableLocationFields = ->
    filters = _.filter getLocationFilters(), (filter) -> getParentLocations(filter).length > 0
    _.map filters, (filter) -> filter.field()
