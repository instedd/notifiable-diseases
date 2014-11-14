@Charts ?= {}

class @Charts.Trendline extends @Charts.Base
  constructor: (fieldsCollection) ->
    super(fieldsCollection)
    @kind = 'Trendline'
    @display = 'simple'
    @grouping = 'year'
    @compareToDate = 'previous_year'
    @splitField = fieldsCollection.allEnum()[0]?.name
    @compareToLocationField = fieldsCollection.allLocation()[0]?.name
    @values = 'count'

  initializeFrom: (data) ->
    @display = data.display
    @splitField = data.splitField
    @grouping = data.grouping
    @compareToDate = data.compareToDate
    @compareToLocation = data.compareToLocation
    @compareToLocationField = data.compareToLocationField
    @values = data.values
    @

  toJSON: ->
    kind: @kind
    display: @display
    splitField: @splitField
    grouping: @grouping
    compareToDate: @compareToDate
    compareToLocation: @compareToLocation
    compareToLocationField: @compareToLocationField
    values: @values

  isConfigurable: ->
    true

  vizType: ->
    switch @display
      when 'compareToDate', 'compareToLocation'
        'LineChart'
      else
        'AreaChart'

  isStacked: ->
    @display != 'compareToDate' && @display != 'compareToLocation'

  displayStrategy: ->
    klazz = switch @display
      when 'simple'
        Charts.Trendline.SimpleDisplay
      when 'split'
        Charts.Trendline.SplitDisplay
      when 'compareToDate'
        Charts.Trendline.DateCompareDisplay
      when 'compareToLocation'
        Charts.Trendline.LocationCompareDisplay
      else
        throw "Unknown display: #{@display}"
    new klazz(@)

  description: (report) ->
    return @displayStrategy().description(report)


  applyToQuery: (query, filters) ->
    return @displayStrategy().applyToQuery(query, filters)


  getSeries: (report, data) ->
    @displayStrategy().getExtendedSeries(report, data)


  getCSV: (report, series) ->
    rows = []
    rows.push ["Date"].concat(series.cols)
    for row in series.rows
      rows.push _.map row, (v) -> if v then v else 0
    rows

  startRendering: (q) -> q.when(true)
