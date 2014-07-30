angular.module('ndApp')
  .controller 'HomePlaygroundCtrl', ($scope, $http, $log) ->
    $scope.data = []
    $scope.query = '{"group_by": "year(created_at)"}'

    applyFilters = (query) ->
      for filter in $scope.filters
        switch filter.kind
          when "Date"
            query.since = filter.since
            query.until = filter.until

      query

    $scope.doQuery = () ->
      query = JSON.parse($scope.query)
      applyFilters(query)

      $http.post("/cdx/v1/events", query).success (data) ->
        $log.debug("Received #{data}")
        $scope.data = data
