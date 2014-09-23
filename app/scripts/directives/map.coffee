angular.module('ndApp')
  .directive 'ndMap', (PolygonService, debounce) ->
    {
      restrict: 'E'
      scope:
        series: '='
        filters: '='
        chart: '='
      template: '<div class="nd-map"></div>',
      link: (scope, element) ->
        new MapWidget(scope, element[0].children[0]).initialize(PolygonService, debounce)
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

  initialize: (polygon_service, debounce) ->
    @map = @create_map(@element)
    @markers = L.layerGroup([]).addTo @map
    @chart = @scope.chart

    # debounce to prevent consecutive updates to trigger concurrent
    # drawings on the map.
    #
    # (beginning to draw a map before a previous one has finished may
    # cause old layers from the 'old' map to be added after the reset
    # call is made)
    @scope.$watchCollection('series', debounce(() =>
      if @scope.series
        admin_level = @scope.chart.groupingLevel(@scope.filters)
        @draw_results(polygon_service, admin_level, @scope.series)
    , 1000, false))

  create_map: (element) ->
    map = L.map(element, { 
      attributionControl: false,
      zoomControl: false,
      minZoom: 2
    })

    us_center = [48.224672, -100.371093]
    us_bounds = [[-1.054627, -182.109375],[73.726594, -18.632812]]

    map.setView(us_center, 2)
    map.setMaxBounds us_bounds

    map.dragging._draggable.on('predrag', () -> 
      currentTopLeft = map._initialTopLeftPoint.subtract(@_newPos)
      currentBounds = new L.Bounds(currentTopLeft, currentTopLeft.add(map.getSize()))
      limitedOffset = map._getBoundsOffset(currentBounds, map.options.maxBounds)
      @_newPos = @_newPos.subtract(limitedOffset)
    )

    L.tileLayer('http://a{s}.acetate.geoiq.com/tiles/acetate-base/{z}/{x}/{y}.png').addTo map

    map

  draw_results: (polygon_service, admin_level, results) ->
    polygon_service.fetch_polygon(@chart.mappingField, admin_level).then (polygons) =>
      @clear_map()
      if results.length > 0
        polygons = @result_polygons(polygons, results)
        @add_polygon_layer(polygons)
        @add_context_layer(polygon_service, polygons, admin_level)
      else
        @map.fitBounds @map.options.maxBounds

  topojson_geometries: (topojson) ->
    object = _.values(topojson.objects)[0]
    if object["type"] == "GeometryCollection"
      object.geometries
    else
      [object]

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
    result_count_by_id = _.object(_.map(results, (e) -> [e[field], e.count]))
    geometries = @topojson_geometries(full_topojson)
    filtered_geometries = _.reduce(geometries, ((r,o) ->
      count_for_location = result_count_by_id[o.properties.ID]
      if count_for_location
        clone = $.extend(true, {}, o)
        clone.properties.event_count = count_for_location
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
      parent_id = geometries[0].properties["PARENT_ID"]
      polygon_service.fetch_polygon(@chart.mappingField, admin_level - 1).then (topojson) =>
        geometries = @topojson_geometries(topojson)
        parent = _.find(geometries, (g) -> g.properties["ID"] == parent_id)
        if parent
          filtered_topojson = @topojson_restrict(topojson, [parent])
          geojson = omnivore.topojson.parse(filtered_topojson)
          @contextLayer = L.geoJson geojson, { style: context_polygon_style }
          @contextLayer.addTo @map

  create_icon: (feature) ->
    count = feature.properties.event_count
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
    <b>#{feature.properties.NAME}</b>
    <br>
    Event count: <em>#{feature.properties.event_count}</em>
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
