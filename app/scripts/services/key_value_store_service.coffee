angular.module('ndApp')
  .service 'KeyValueStore', ($http, settings) ->
    keyUri = (key, version = null) ->
      if version
        "#{settings.store}/#{key}?version=#{version}"
      else
        "#{settings.store}/#{key}"

    get: (key) ->
      $http.get keyUri(key)

    put: (key, value, version = null) ->
      $http.post keyUri(key, version), value

    delete: (key) ->
      $http.delete keyUri(key)
