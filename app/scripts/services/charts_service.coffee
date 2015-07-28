angular.module('ndApp')
  .service 'ChartsService', (settings) ->
    create: (klass, fieldsCollection) ->
      chart = new Charts[klass](fieldsCollection)
      chart

    deserialize: (chartData, fieldsCollection) ->
      new Charts[chartData.kind](fieldsCollection).initializeFrom(chartData)

