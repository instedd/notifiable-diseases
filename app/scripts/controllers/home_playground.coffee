angular.module('ndApp')
  .controller 'HomePlaygroundCtrl', ($scope, $http, $log, FiltersService) ->
    $scope.data = []
    $scope.query = '{"group_by": "year(created_at)"}'

    $scope.doQuery = () ->
      query = JSON.parse($scope.query)
      FiltersService.applyFilters(query)

      $http.post("/cdx/v1/events", query).success (data) ->
        $log.debug("Received #{data}")
        $scope.data = data
