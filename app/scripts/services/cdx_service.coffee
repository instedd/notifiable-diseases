angular.module('ndApp')
  .service 'Cdx', ($http, settings) ->
    events: (query) ->
      $http.post("#{settings.api}/events", query)

