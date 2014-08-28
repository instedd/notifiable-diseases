'use strict'

angular.module('ndApp')
  .controller 'LocationFilterCtrl', ($scope, FieldsService) ->
    $scope.flattenedLocations = FieldsService.flattenedLocations($scope.filter.name)

    $scope.$watch 'location_str', (newValue, oldValue) ->
      if oldValue != newValue
        $scope.filter.location = newValue && JSON.parse(newValue)

    $scope.$watch 'filter.location', (newValue, oldValue) ->
      if oldValue != newValue
        $scope.location_str = newValue && JSON.stringify(newValue)

    $scope.select2Options =
      formatResultCssClass: (element) ->
        level = $(element.element[0]).data("level");
        if level then "depth#{level}" else ""
