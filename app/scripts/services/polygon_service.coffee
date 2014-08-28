angular.module('ndApp').service 'PolygonService', ($q, $http, settings) ->

  polygon_urls = settings.polygonUrls

  cache = {}

  service =
    fetch_polygon: (admin_level) ->
      q = $q.defer()
      
      if cache[admin_level]
        q.resolve cache[admin_level]
      else if polygon_urls[admin_level]
        $http.get(polygon_urls[admin_level]).success (data) ->
          cache[admin_level] = data
          q.resolve(data)
      else
        q.reject "No url configured to fetch polygons of level #{admin_level}"

      q.promise
