'use strict'

###*
 # @ngdoc function
 # @name notifiableDiseasesApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the notifiableDiseasesApp
###

angular.module('ndApp').controller 'MainCtrl', ($scope, $http, $log) ->
  $scope.data = []
  $scope.query = '{"group_by": "year(created_at)"}'

  $scope.doQuery = () ->
    $http.post("http://localhost:3000/cdx/v1/events", JSON.parse($scope.query)).success (data) ->
      $log.debug("Received #{data}")
      $scope.data = data
