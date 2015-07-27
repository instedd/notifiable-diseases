@Charts ?= {}

class @Charts.Trendline.SimpleDisplay extends @Charts.Trendline.BaseDisplay

  applyToQuery: (query, filters) ->
    query.group_by = @dateGrouping
    if @values == 'percentage' then [@numeratorFor(query), @denominatorFor(query)] else [query]

  getSeries: (report, data) ->
    datapoints = data[0].tests
    denominators = if @values == 'percentage' and data.length > 0 then data[1].tests else null

    @getSimpleSeries(datapoints, denominators)

