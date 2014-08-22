'use strict'

angular.module('ndApp')
  .controller 'LocationFilterCtrl', ($scope, FieldsService) ->
    $scope.flattenedLocations = FieldsService.flattenedLocations($scope.filter.name)
    $scope.select2Options =
      formatResultCssClass: (element) ->
        level = $(element.element[0]).data("level");
        if level then "depth#{level}" else ""


