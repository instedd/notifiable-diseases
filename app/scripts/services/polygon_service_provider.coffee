angular.module('ndApp').service 'PolygonServiceProvider', (StaticPolygonService, RemoteLocationsServiceFactory, $q, settings) ->

  class RemoteLocationsPolygonService
    constructor: (locations) ->
      @locations = locations

    polygons: (field, grouping, resultsById) =>
      q = $q.defer()
      ids = _.keys(resultsById)

      if grouping.level > 0
        ids = ids.concat(grouping.parents)

      @locations.details(ids,
        ancestors: false
        shapes: true
        simplify: settings.simplifyShapes
      ).success (polygons) ->
        q.resolve(_.partition(polygons, (p) -> resultsById[p.id]?))
      q.promise

    parent_polygons: (field, grouping) ->
      q = $q.defer()
      if grouping.level == 0
        q.resolve([])
      else
        @locations.details(grouping.parents,
          ancestors: false
          shapes: true
          simplify: settings.simplifyShapes
        ).success (parentPolygons) ->
          q.resolve(parentPolygons)
      q.promise

  provider =
    create_for: (field) ->
      if field.remote
        new RemoteLocationsPolygonService(field.locations)
      else
        StaticPolygonService

