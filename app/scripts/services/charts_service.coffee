angular.module('ndApp')
  .service 'ChartsService', (settings) ->
    Charts.Map.setAvailablePolygonLevels _.mapValues(settings.polygons, (p) -> _.max(_.keys(p)))

    create: (klass, fieldsCollection) ->
      chart = new Charts[klass](fieldsCollection)
      chart

    deserialize: (chartData, fieldsCollection) ->
      new Charts[chartData.kind](fieldsCollection).initializeFrom(chartData)

