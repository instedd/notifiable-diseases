'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:PlaygroundCtrl
 # @description
 # # PlaygroundCtrl
 # Manages playground page
###

angular.module('ndApp').controller 'PlaygroundCtrl', ($scope, $http, $log) ->
  $scope.data = []
  $scope.query = '{"group_by": "year(created_at)"}'

  $scope.doQuery = () ->
    $http.post("/cdx/v1/events", JSON.parse($scope.query)).success (data) ->
      $log.debug("Received #{data}")
      $scope.data = data
