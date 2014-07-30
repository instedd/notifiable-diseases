'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:TrendlineCtrl
 # @description
 # # TrendlineCtrl
 # Manages trendline test page
###

angular.module('ndApp').controller 'TrendlineCtrl', ($scope, $http, $log) ->

  $scope.data = [
    { created_at:"2011", count:494},
    { created_at:"2012", count:223},
    { created_at:"2013", count:80},
    { created_at:"2014", count:10}
  ]

  $scope.data_str = JSON.stringify($scope.data, null, 2)

  $scope.doUpdate = () =>
    $scope.data = JSON.parse($scope.data_str)