angular.module('ndApp')
  .directive 'ndMap', (PolygonService) ->
    {
      restrict: 'E'
      scope:
        series: '='
        filters: '='
        chart: '='
      template: '<div class="nd-map"></div>',
      link: (scope, element, attrs) ->
        
        @map = create_map(element[0].children[0])
        @markers = L.layerGroup([]).addTo @map

        scope.$watchCollection('series', () ->
          if scope.series
            admin_level = scope.chart.groupingLevel(scope.filters)
            PolygonService.fetch_polygon(admin_level).then (polygons) ->
              draw_results(polygons, scope.series)
        )
    }

create_map = (element) =>
  map = L.map(element, { 
    attributionControl: false,
    zoomControl: false,
    minZoom:3,
  })
     
  map.setView([35.981250, -96.148398], 3)
  map.setMaxBounds map.getBounds()

  map.dragging._draggable.on('predrag', () -> 
    currentTopLeft = map._initialTopLeftPoint.subtract(@._newPos)
    currentBounds = new L.Bounds(currentTopLeft, currentTopLeft.add(map.getSize()))
    limitedOffset = map._getBoundsOffset(currentBounds, map.options.maxBounds)
    @_newPos = @._newPos.subtract(limitedOffset)
  )

  L.tileLayer('http://a{s}.acetate.geoiq.com/tiles/acetate-base/{z}/{x}/{y}.png').addTo map

  map

draw_results = (polygons, results) =>
  clear_map()
  if results.length > 0
    polygons = build_polygons(polygons, results)
    draw_polygons(polygons)
  else
    @map.fitBounds @map.options.maxBounds

build_polygons = (full_topojson, results) ->
  result_count_by_id = _.object(_.map(results, (e) -> [e.location, e.count]))
  object = _.values(full_topojson.objects)[0]

  if object["type"] == "GeometryCollection"
    geometries = object.geometries
  else
    geometries = [object]

  filtered_geometries = _.reduce(geometries,
                                  (r,o) ->
                                    count_for_location = result_count_by_id[o.properties.GEO_ID]
                                    if count_for_location
                                      clone = $.extend(true, {}, o)
                                      clone.properties.event_count = count_for_location
                                      r.push clone
                                    r
                                  [])

  # TODO: consider keeping only arcs needed by filtered geometries
  filtered_topojson =
    type: "Topology",
    objects:
      locations:
        type: "GeometryCollection",
        geometries: filtered_geometries
    arcs: full_topojson.arcs,
    transform: full_topojson.transform

  omnivore.topojson.parse(filtered_topojson)

on_each_feature = (feature, layer) =>

  layer_center = layer.getBounds().getCenter()

  popup_content = "
  <b>#{feature.properties.NAME}</b>
  <br>
  Event count: <em>#{feature.properties.event_count}</em>
  "
  
  popup = L.popup({closeButton : false, autoPan: false})
           .setLatLng(layer_center)
           .setContent(popup_content)

  L.marker(layer_center)
   .addTo @markers
   .bindPopup popup

clear_map = () =>
  @map.removeLayer(@polygonLayer) if @polygonLayer
  @markers.clearLayers()

draw_polygons = (polygons) =>
  layout_options =
    style:
       weight: 1,
       fillOpacity: 0.1
    onEachFeature: on_each_feature

  @polygonLayer = L.geoJson(polygons, layout_options)
  
  @map.fitBounds @polygonLayer.getBounds()
  @polygonLayer.addTo @map