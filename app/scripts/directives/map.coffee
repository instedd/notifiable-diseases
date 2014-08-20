angular.module('ndApp')
  .directive 'ndMap', () ->
    {
      restrict: 'E'
      # scope:
      #   series: '='
      #   title: '='
      template: '<div class="nd-map"></div>',
      link: (scope, element, attrs) ->
        # bounds need to be slightly wider than initial zoom to avoid automatic zoom in
        bounds = L.latLngBounds(L.latLng([9.387811882056695,-139.42734375]),
                                L.latLng([56.67911044801047,-56.69734375]));

        map = L.map(element[0].children[0], { attributionControl: false, minZoom:3})
               .setView([35.981250, -96.148398], 3)

        map.setMaxBounds(bounds)
        L.tileLayer('http://a{s}.acetate.geoiq.com/tiles/acetate-base/{z}/{x}/{y}.png').addTo(map);
        
        polygons_by_level = {
          0: NNDD.us_outline
          1: NNDD.us_states
          2: NNDD.us_counties
        }

        # --- draw sample data

        # retrieved via API
        data = sample_response

        # configured in chart settings
        admin_level = 1
        
        polygons = build_polygons(polygons_by_level[admin_level], data)
        draw_results(map, polygons)
    }

# select polygons for which there are results
# and attach event count properties.
build_polygons = (all_polygons, results) ->
  result_count_by_id = _.object(_.map(results.events, (e) -> [e.location_id, e.count]))

  polygons_to_show = _.reduce(all_polygons.features,
                              (r,f) ->
                                count_for_location = result_count_by_id[f.properties.GEO_ID]
                                if count_for_location
                                  clone = $.extend(true, {}, f)
                                  clone.properties.event_count = count_for_location;
                                  r.push clone
                                r
                              [])  
  polygons_to_show


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

sample_response = {
  "events": [
    {
      "location_id": "0400000US04",
      "count": 73
    },
    {
      "location_id": "0400000US06",
      "count": 66
    },
    {
      "location_id": "0400000US36",
      "count": 64
    }
  ],
  "total_count": 203
}
