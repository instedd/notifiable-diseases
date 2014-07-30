angular.module('ndApp')
  .controller 'HomePlaygroundCtrl', ($scope, $http, $log) ->
    $scope.query = '{"group_by": "year(created_at)"}'

    applyFilters = (query) ->
      for filter in $scope.filters
        filter.applyTo(query)
      query

    $scope.doQuery = () ->
      query = JSON.parse($scope.query)
      applyFilters(query)

      $http.post("/cdx/v1/events", query).success (data) ->
        $log.debug("Received #{data}")
        $scope.data.series = data
