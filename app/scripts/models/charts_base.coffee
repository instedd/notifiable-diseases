@Charts ?= {}

class @Charts.Base

  constructor: (fieldsCollection) ->
    @fieldsCollection = () -> fieldsCollection
    @validResults = _.map fieldsCollection.result_field().validResults(), 'value'
    @positiveResults = _.map fieldsCollection.result_field().positiveResults, 'value'
    @resultsToShow = _.map fieldsCollection.result_field().results(), 'value'

  denominatorFor: (query) ->
    denominator = _.cloneDeep query
    denominator.result = @validResults
    denominator
  numeratorFor: (query) ->
    numerator = _.cloneDeep query
    numerator.result ?= @positiveResults
    numerator
