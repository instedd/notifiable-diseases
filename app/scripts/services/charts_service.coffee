angular.module('ndApp')
  .service 'ChartsService', (settings) ->
    create: (klass, resource, fieldsCollection) ->
      chart = new Charts[klass](resource, fieldsCollection)
      chart

    deserialize: (chartData, resource, fieldsCollection) ->
      new Charts[chartData.kind](resource, fieldsCollection).initializeFrom(chartData)

