charts = ["PopulationPyramid", "Trendline", "Map"]

angular.module('ndApp')
  .service 'ChartsService', [charts..., (args...)->
    klasses = {}
    _.map _.zip(charts, args), (element) ->
      klasses[element[0]] = element[1]

    create: (klass) ->
      new klasses[klass]

    deserialize: (chart) ->
      klasses[chart.kind].deserialize(chart)
  ]

