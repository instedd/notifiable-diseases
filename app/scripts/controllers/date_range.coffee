'use strict'

angular.module('ndApp')
  .controller 'DateRangeCtrl', ($scope) ->
    $scope.dateRange =
      startDate: moment($scope.filter.since)
      endDate: moment($scope.filter.until)
    $scope.$watch 'dateRange', ->
      $scope.filter.since = moment($scope.dateRange.startDate).format("YYYY-MM-DD")
      $scope.filter.until = moment($scope.dateRange.endDate).format("YYYY-MM-DD")
