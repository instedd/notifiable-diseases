angular.module('ndApp')
  .service 'ChartsService', (settings) ->
    Charts.Map.setMaxAvailablePolygonLevel _.max(_.keys(settings.polygons))

    create: (klass, fieldsCollection) ->
      chart = new Charts[klass](fieldsCollection)
      chart

    deserialize: (chartData, fieldsCollection) ->
      new Charts[chartData.kind](fieldsCollection).initializeFrom(chartData)

