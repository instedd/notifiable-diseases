@Charts ?= {}

class @Charts.Base

  constructor: (fieldsCollection) ->
    @fieldsCollection = () -> fieldsCollection
    @validResults = _.map fieldsCollection.result_field().validResults(), 'value'

  denominatorFor: (query) ->
    denominator = _.cloneDeep query
    denominator.result = @validResults
    denominator
