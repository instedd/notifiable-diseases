angular.module('ndApp')
  .controller 'HomePlaygroundCtrl', ($scope, $http, $log) ->
    $scope.data = []

    applyFilters = (query) ->
      for filter in $scope.currentReport.filters
        filter.applyTo(query)
      query

    $scope.doQuery = () ->
      query = JSON.parse($scope.currentReport.query)
      applyFilters(query)

      $http.post("/cdx/v1/events", query).success (data) ->
        $log.debug("Received #{data}")
        $scope.data.series = data
