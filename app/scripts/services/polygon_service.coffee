angular.module('ndApp').service 'StaticPolygonService', ($q, $http, settings) ->

  polygon_urls = settings.polygons

  cache = {}

  service =
    polygons: (field, grouping, ids) ->
      q = $q.defer()
      service.fetch_polygon(field, grouping.level).then (polygons) ->
        polygons = _.filter polygons, (polygon) -> ids[polygon.id]
        service.parent_polygons(field, grouping).then (parentPolygons) ->
          q.resolve([polygons, parentPolygons])
      q.promise

    parent_polygons: (field, grouping) ->
      q = $q.defer()
      if grouping.level == 0
        q.resolve([])
      else
        service.fetch_polygon(field, grouping.level-1).then (parentPolygons) ->
          parentPolygon = _.find parentPolygons, (polygon) -> _.contains(grouping.parents, polygon.id)
          q.resolve([parentPolygon])

      q.promise

    fetch_polygon: (field, admin_level) ->
      q = $q.defer()
      url = polygon_urls[field]?[admin_level]

      if url
        if cache[url]
          q.resolve cache[url]
        else
          $http.get(url).success (data) ->
            locations = _.map omnivore.topojson.parse(data), (polygon) ->
              id: polygon.properties.ID
              name: polygon.properties.NAME
              parent_id: polygon.properties.PARENT_ID
              lat: polygon.properties.LATITUDE
              lng: polygon.properties.LONGITUDE
              shape: polygon.geometry

            cache[url] = locations
            q.resolve(locations)
      else
        q.reject "No url configured to fetch polygons for field #{field} of level #{admin_level}"

      q.promise

