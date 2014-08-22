angular.module('ndApp')
  .directive 'ndMap', () ->
    {
      restrict: 'E'
      # scope:
      #   series: '='
      #   title: '='
      template: '<div class="nd-map"></div>',
      link: (scope, element, attrs) ->
        map = L.map(element[0].children[0], { attributionControl: false, zoomControl: false, minZoom:3})
               
        map.setView([35.981250, -96.148398], 3)
        map.dragging.disable()
        map.touchZoom.disable()
        map.doubleClickZoom.disable()
        map.scrollWheelZoom.disable()

        L.tileLayer('http://a{s}.acetate.geoiq.com/tiles/acetate-base/{z}/{x}/{y}.png').addTo(map);
        
        polygons_by_level = {
          0: NNDD.us_outline_topo
          1: NNDD.us_states_topo
          2: NNDD.us_counties_topo
        }

        # --- draw sample data

        # configured in chart settings
        admin_level = 1

        # retrieved via API
        data = sample_data[admin_level]
        
        polygons = build_polygons(polygons_by_level[admin_level], data)
        draw_results(map, polygons)
    }

build_polygons = (full_topojson, results) ->
  result_count_by_id = _.object(_.map(results.events, (e) -> [e.location_id, e.count]))

  geometries = _.values(full_topojson.objects)[0].geometries
  filtered_geometries = _.reduce(geometries,
                                  (r,o) ->
                                    count_for_location = result_count_by_id[o.properties.GEO_ID]
                                    if count_for_location
                                      clone = $.extend(true, {}, o)
                                      clone.properties.event_count = count_for_location;
                                      r.push clone
                                    r
                                  [])

  # TODO: consider keeping only arcs needed by filtered geometries
  filtered_topojson = {
    "type": "Topology",
    "objects": {
      "locations": {
        "type": "GeometryCollection",
        "geometries": filtered_geometries
      }
    }
    "arcs" : full_topojson.arcs,
    "transform": full_topojson.transform
  }
  omnivore.topojson.parse(filtered_topojson)


draw_results = (map, polygons) ->
  on_each_feature = (feature, layer) ->
    layer.on {
      mouseover: () -> console.log("#{feature.properties.NAME}: #{feature.properties.event_count}")
    }

  layout_options =
    style:
       weight: 1,
       fillOpacity: 0.1
    onEachFeature: on_each_feature

  L.geoJson(polygons, layout_options).addTo(map)



# ------------------------------------

sample_data = {
  1:
    events: [
      { location_id: "0400000US04", count: 73 },
      { location_id: "0400000US06", count: 66 },
      { location_id: "0400000US36", count: 64 }
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