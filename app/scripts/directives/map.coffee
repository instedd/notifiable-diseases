angular.module('ndApp')
  .directive 'ndMap', ($q, PolygonServiceProvider, debounce, settings) ->
    {
      restrict: 'E'
      scope:
        series: '='
        filters: '='
        chart: '='
      template: '<div class="nd-map"></div>',
      link: (scope, element) ->
        new MapWidget(scope, element[0].children[0]).initialize($q, PolygonServiceProvider, debounce, settings)
    }


class MapWidget

  constructor: (scope, element) ->
    @scope = scope
    @element = element

  initialize: (q, polygon_service_provider, debounce, settings) =>

    @showPositive = settings.onlyShowPositiveResults
    @showMarkersOnMap = settings.showMarkersOnMap
    @chart = @scope.chart

    polygon_service = polygon_service_provider.create_for(@chart.field())

    @map = @create_map @element,
      settings.mapCenter,
      settings.mapBounds,
      settings.mapProviderUrl,
      settings.mapProviderSettings

    @markers = L.layerGroup([]).addTo @map

    @polygon_style = {
      weight: 1,
      fillOpacity: 0.1
      clickable: !@showMarkersOnMap
    }

    @context_polygon_style = {
      fillColor: '#E0DFEG',
      stroke: false
      fillOpacity: 0.1
      clickable: false
    }

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
        grouping = @scope.chart.groupingInfo(@scope.filters)
        @draw_results(polygon_service, grouping, @scope.series)
    , 1000, false))

  create_map: (element, map_center, map_bounds, map_provider_url, map_provider_settings={}) =>
    map = L.map(element, {
      attributionControl: false,
      zoomControl: true,
      scrollWheelZoom: false,
      minZoom: 2
    })

    map.setView(map_center, 2)

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

  beginRendering: (q) =>
    @polygonsRendering = q.defer()
    @contextRendering = q.defer()

    # TO-DO: timeout and fail cases?
    q.all([@polygonsRendering, @contextRendering])
     .then => @chart.doneRendering()


  clear_map: () =>
    @map.removeLayer(@polygonLayer)  if @polygonLayer
    @map.removeLayer(@contextLayer) if @contextLayer
    @markers.clearLayers()


  draw_results: (polygon_service, grouping, results) =>
    @clear_map()
    if results.length > 0
      field = @chart.mappingField
      resultsById = _.object(_.map(results, (e) -> [e[field], e]))
      polygon_service.polygons(@chart.mappingField, grouping, resultsById).then ([polygons, contextPolygons]) =>
        @add_polygon_layer(polygons, resultsById)
        @add_context_layer(contextPolygons)
    else
      @polygonsRendering.resolve()
      polygon_service.parent_polygons(@chart.mappingField, grouping).then (contextPolygons) =>
        @add_context_layer(contextPolygons, true)


  add_polygon_layer: (polygons, resultsById) =>
    layer_options =
      style: @polygon_style
      onEachFeature: @on_each_feature(resultsById)

    @polygonLayer = L.geoJson(@as_geojson(polygons), layer_options)
    @map.fitBounds @polygonLayer.getBounds()
    @polygonLayer.addTo @map
    @polygonsRendering.resolve()


  add_context_layer: (polygons, fitBounds=false) =>
    unless _.isEmpty(polygons)
      @contextLayer = L.geoJson @as_geojson(polygons), { style: @context_polygon_style }
      @contextLayer.addTo @map
      @map.fitBounds @contextLayer.getBounds() if fitBounds
    else if fitBounds
      @map.fitBounds(@map.options.maxBounds) if @map.options.maxBounds
    @contextRendering.resolve()


  as_geojson: (locations) =>
    _.compact _.map locations, (location) ->
      type: 'Feature'
      geometry: location.shape
      properties:
        id: location.id
        name: location.name
        lat: location.lat
        lng: location.lng


  on_each_feature: (resultsById) =>
    return (feature, layer) =>

      layer_center = if feature.lat? && feature.lng? then [feature.lat, feature.lng] else layer.getBounds().getCenter()
      result = resultsById[feature.properties.id]

      popup_content = "
      <b>#{feature.properties.name}</b><br/>
      Positivity: #{(result.percentage * 100).toFixed(2)}%<br/>
      #{if @showPositive then 'Positive events' else 'Valid events'}: <em>#{result.positive}</em><br/>
      Total events: <em>#{result.count}</em>"

      popup = L.popup({closeButton : false, autoPan: false})
               .setLatLng(layer_center)
               .setContent(popup_content)

      count = result.percentage * 100
      if count >= @chart.thresholds.upper
        color = 'red'
      else if count >= @chart.thresholds.lower
        color = 'yellow'
      else
        color = 'green'

      if @showMarkersOnMap
        icon = L.divIcon { className: "nd-map-marker #{color}" }
        marker = L.marker(layer_center, { icon: icon })
        marker.addTo @markers
              .bindPopup popup
      else
        layer.setStyle({color: color})
        layer.bindPopup popup
