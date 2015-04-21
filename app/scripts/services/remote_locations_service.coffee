angular.module('ndApp').service 'RemoteLocationsServiceFactory', ($q, $http) ->

  class RemoteLocationsService

    constructor: (config) ->
      @url = config.url
      @set = config.set

    suggest: (name, opts={}) ->
      opts['name'] = name
      opts['set'] = @set
      $http.get("#{@url}/suggest", {params: opts})

    details: (id, opts={}) ->
      ids = [].concat(id).join(",")
      opts['id'] = ids
      opts['set'] = @set
      $http.get("#{@url}/details", {params: opts})


  factory =
    createService: (config) ->
      new RemoteLocationsService(config)
