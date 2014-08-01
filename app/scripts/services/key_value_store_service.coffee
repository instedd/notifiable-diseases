angular.module('ndApp')
  .service 'KeyValueStore', ($http) ->
    keyUri = (key, version = null) ->
      if version
        "/store/#{key}?version=#{version}"
      else
        "/store/#{key}"

    get: (key) ->
      $http.get keyUri(key)

    put: (key, value, version = null) ->
      $http.post keyUri(key, version), value

    delete: (key) ->
      $http.delete keyUri(key)
