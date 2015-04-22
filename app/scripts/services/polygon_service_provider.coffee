angular.module('ndApp').service 'PolygonServiceProvider', (StaticPolygonService, RemoteLocationsServiceFactory, $q, settings) ->

  class RemoteLocationsPolygonService
    initialize: (locations) ->
      @locations = locations

    polygons: (field, grouping, ids) =>
      q = $q.defer()
      ids = _.keys(ids)

      if grouping.level > 0
        ids += grouping.parents

      @locations.details(ids,
        ancestors: false
        shapes: true
        simplify: settings.simplifyShapes
      ).success (polygons) ->
        q.resolve(_.partition(polygons, (p) -> not _.contains(grouping.parents, p.id)))
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

