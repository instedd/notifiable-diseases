@Charts ?= {}

class @Charts.Trendline.SimpleDisplay extends @Charts.Trendline.BaseDisplay

  applyToQuery: (query, filters) ->
    query.group_by = @dateGrouping
    [query]

  getSeries: (report, data) ->
    data = data[0].events
    @getSimpleSeries(data)

