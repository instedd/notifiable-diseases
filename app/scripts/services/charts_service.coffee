# CODEREVIEW: Instead of listing explicitly all classes, add a run handler in the declaration of each class so it adds itself to a global dictionary. Alternatively, configure coffee so it does not wrap each file on its own context, so all classes are globally available.
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

