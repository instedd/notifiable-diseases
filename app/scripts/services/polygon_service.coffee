angular.module('ndApp').service 'PolygonService', ($q, $http, settings) ->

  polygon_urls = settings.polygons

  cache = {}

  service =
    fetch_polygon: (field, admin_level) ->
      q = $q.defer()

      url = polygon_urls[field]?[admin_level]

      if url
        if cache[url]
          q.resolve cache[url]
        else
          $http.get(url).success (data) ->
            cache[url] = data
            q.resolve(data)
      else
        q.reject "No url configured to fetch polygons for field #{field} of level #{admin_level}"

      q.promise
