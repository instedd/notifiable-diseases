angular.module('ndApp')
  .directive 'ndMap', () ->
    {
      restrict: 'E'
      template: '<div class="nd-map"></div>',
      link: (scope, element, attrs) ->
        
        @map = create_map(element[0].children[0])

        @polygons_by_level = {
          0: NNDD.us_outline_topo
          1: NNDD.us_states_topo
          2: NNDD.us_counties_topo
        }

        # --- draw sample data

        # configured in chart settings
        admin_level = 2

        # retrieved via API
        results = sample_data[admin_level]
        
        draw_results(admin_level, results)
    }

create_map = (element) =>
  map = L.map(element, { 
    attributionControl: false,
    zoomControl: false,
    minZoom:3,
    touchZoom: false,
    doubleClickZoom: false,
    scrollWheelZoom: false
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

draw_results = (admin_level, results) =>
  polygons = build_polygons(@polygons_by_level[admin_level], results)
  draw_polygons(polygons)

build_polygons = (full_topojson, results) ->
  result_count_by_id = _.object(_.map(results.events, (e) -> [e.location_id, e.count]))

  geometries = _.values(full_topojson.objects)[0].geometries
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
   .addTo @map
   .bindPopup popup

draw_polygons = (polygons) =>
  @map.removeLayer(@polygonLayer) if @polygonLayer

  layout_options =
    style:
       weight: 1,
       fillOpacity: 0.1
    onEachFeature: on_each_feature

  @polygonLayer = L.geoJson(polygons, layout_options)
  
  @map.fitBounds @polygonLayer.getBounds()
  @polygonLayer.addTo @map



# ------------------------------------

sample_data = {
  1:
    events: [
      { location_id: "0400000US04", count: 73 },
      { location_id: "0400000US06", count: 66 },
    ],
    total_count: 203
  2:
    events: [
      { location_id: "0500000US06071", count: 73 },
      { location_id: "0500000US04005", count: 66 },
      { location_id: "0500000US32023", count: 64 }
    ],
    total_count: 203
}