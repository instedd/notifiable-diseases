'use strict'

angular.module('ndApp').controller 'MapConfigCtrl', ($scope) ->
    $scope.locationFields = () ->
      $scope.report.fieldsCollection().allLocation()

