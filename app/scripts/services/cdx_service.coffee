angular.module('ndApp')
  .service 'Cdx', ($http, settings) ->
    events: (query) ->
      $http.post "#{settings.api}/events", query

    fields: (context = {}) ->
      $http.get "#{settings.api}/events/schema?#{$.param context}"

