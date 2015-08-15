angular.module('ndApp')
  .directive 'ndMap', ($q, PolygonService, debounce, settings) ->
    {
      restrict: 'E'
      scope:
        series: '='
        filters: '='
        chart: '='
      template: '<div class="nd-map"></div>',
      link: (scope, element) ->
        new MapWidget(scope, element[0].children[0]).initialize($q, PolygonService, debounce, settings)
    }

polygon_style = {
  weight: 1,
  fillOpacity: 0.1
  clickable: false
}

context_polygon_style = {
  fillColor: '#E0DFEG',
  stroke: false
  fillOpacity: 0.1
  clickable: false
}

class MapWidget

  constructor: (scope, element) ->
    @scope = scope
    @element = element

  initialize: (q, polygon_service, debounce, settings) ->

    @showPositive = settings.onlyShowPositiveResults
    @map = @create_map(@element, settings.mapCenter, settings.mapBounds, settings.mapProviderUrl, settings.mapProviderSettings)
    @markers = L.layerGroup([]).addTo @map
    @chart = @scope.chart

    # debounce to prevent consecutive updates to trigger concurrent
    # drawings on the map.
    #
    # (beginning to draw a map before a previous one has finished may
    # cause old layers from the 'old' map to be added after the reset
    # call is made)
    #
    # Use $watch instead of $watchCollection to trigger the rendering
    # finish events even if the items in the series don't change. This
    # works because the controller will always replace the series array
    # instead of mutating it (see ChartCtrl#render).
    @scope.$watch('series', debounce(() =>
      if @scope.series
        @beginRendering(q)
        admin_level = @scope.chart.groupingLevel(@scope.filters)
        @draw_results(polygon_service, admin_level, @scope.series)
    , 1000, false))

  create_map: (element, map_center, map_bounds, map_provider_url, map_provider_settings={}) ->
    map = L.map(element, {
      attributionControl: false,
      zoomControl: true,
      scrollWheelZoom: false,
      minZoom: 1
    })

    map.setView(map_center, 1)

    if map_bounds?
      map.setMaxBounds(map_bounds)
      map.dragging._draggable.on('predrag', () ->
        currentTopLeft = map._initialTopLeftPoint.subtract(@_newPos)
        currentBounds = new L.Bounds(currentTopLeft, currentTopLeft.add(map.getSize()))
        limitedOffset = map._getBoundsOffset(currentBounds, map.options.maxBounds)
        @_newPos = @_newPos.subtract(limitedOffset)
      )

    L.tileLayer(map_provider_url, map_provider_settings).addTo map

    map

  beginRendering: (q) ->
    @polygonsRendering = q.defer()
    @contextRendering = q.defer()

    # TO-DO: timeout and fail cases?
    q.all([@polygonsRendering, @contextRendering])
     .then => @chart.doneRendering()


  draw_results: (polygon_service, admin_level, results) ->
    polygon_service.fetch_polygon(@chart.mappingField, admin_level).then (polygons) =>
      @clear_map()
      if results.length > 0
        polygons = @result_polygons(polygons, results)
        @add_polygon_layer(polygons)
        @add_context_layer(polygon_service, polygons, admin_level)
      else
        @polygonsRendering.resolve()
        @contextRendering.resolve()
        @map.fitBounds @map.options.maxBounds

  topojson_geometries: (topojson) ->
    _.flatten _.map(topojson.objects, (o) ->
      if o["type"] == "GeometryCollection"
        o.geometries
      else
        [o]
    )

  # TODO: consider keeping only arcs needed by filtered geometries
  topojson_restrict: (full_topojson, filtered_geometries) ->
    {
      type: "Topology",
      objects:
        locations:
          type: "GeometryCollection",
          geometries: filtered_geometries
      arcs: full_topojson.arcs,
      transform: full_topojson.transform
    }

  result_polygons: (full_topojson, results) ->
    field = @chart.mappingField
    result_counts_by_id = _.object(_.map(results, (e) -> [e[field], e]))
    geometries = @topojson_geometries(full_topojson)
    filtered_geometries = _.reduce(geometries, ((r,o) ->
      counts_for_location = result_counts_by_id[o.properties.ID]
      if counts_for_location
        clone = $.extend(true, {}, o)
        $.extend(clone.properties, counts_for_location)
        r.push clone
      r
    ), [])
    @topojson_restrict(full_topojson, filtered_geometries)

  clear_map: () ->
    @map.removeLayer(@polygonLayer)  if @polygonLayer
    @map.removeLayer(@contextLayer) if @contextLayer
    @markers.clearLayers()

  add_context_layer: (polygon_service, polygons, admin_level) ->
    geometries =  polygons.objects.locations.geometries
    if admin_level > 0 and geometries.length > 0
      parent_ids = _.uniq _.map(geometries, (g) -> g.properties["PARENT_ID"])
      polygon_service.fetch_polygon(@chart.mappingField, admin_level - 1).then (topojson) =>
        geometries = @topojson_geometries(topojson)
        parents = _.filter geometries, (g) -> _.include(parent_ids, g.properties["ID"])

        unless _.isEmpty(parents)
          filtered_topojson = @topojson_restrict(topojson, parents)
          geojson = omnivore.topojson.parse(filtered_topojson)
          @contextLayer = L.geoJson geojson, { style: context_polygon_style }
          @contextLayer.addTo @map

    @contextRendering.resolve()

  create_icon: (feature) ->
    count = feature.properties.percentage * 100
    if count >= @chart.thresholds.upper
      color = 'red'
    else if count >= @chart.thresholds.lower
      color = 'yellow'
    else
      color = 'green'

    L.divIcon { className: "nd-map-marker #{color}" }

  on_each_feature: (feature, layer) =>
    layer_center = layer.getBounds().getCenter()

    popup_content = "
    <b>#{feature.properties.NAME} #{(feature.properties.percentage * 100).toFixed(2)}%</b><br/>
    #{if @showPositive then 'Positive events' else 'Valid events'}: <em>#{feature.properties.positive}</em><br/>
    Total events: <em>#{feature.properties.count}</em>
    "

    popup = L.popup({closeButton : false, autoPan: false})
             .setLatLng(layer_center)
             .setContent(popup_content)

    marker = L.marker(layer_center, { icon: @create_icon(feature) })

    marker.addTo @markers
          .bindPopup popup

  add_polygon_layer: (polygons) ->
    geojson = omnivore.topojson.parse(polygons)

    layer_options =
      style: polygon_style
      onEachFeature: @on_each_feature

    @polygonLayer = L.geoJson(geojson, layer_options)

    @map.fitBounds @polygonLayer.getBounds()
    @polygonLayer.addTo @map
    @polygonsRendering.resolve()
