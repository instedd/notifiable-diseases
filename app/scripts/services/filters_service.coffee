filters = ["DateFilter", "EthnicityFilter", "GenderFilter"]

angular.module('ndApp')
  .service 'FiltersService', [filters..., (args...)->
    klasses = {}
    _.map _.zip(filters, args), (element) ->
      klasses[element[0]] = element[1]

    create: (klass) ->
      new klasses[klass]

    deserialize: (filter) ->
      klasses[filter.kind].deserialize(filter)
  ]
