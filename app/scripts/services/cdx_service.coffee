angular.module('ndApp')
  .service 'Cdx', ($http) ->
    events: (query) ->
      $http.post("/cdx/v1/events", query)

