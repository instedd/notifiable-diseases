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
    return @displayStrategy().description()

    # desc = "Events grouped by #{@grouping}"
    # switch @display
    #   when 'split'
    #     splitField = @fieldsCollection().find(@splitField)
    #     desc += ", split by #{splitField?.label.toLowerCase()}"
    #   when 'compareToDate'
    #     switch @compareToDate
    #       when 'previous_year'
    #         desc += ", compared to previous year"
    #       else
    #         throw "Unknown compare to value: #{@compareToDate}"
    #   when 'compareToLocation'
    #     location = @getCompareToLocation(report.filters)
    #     if location
    #       compareField = @fieldsCollection().find(@compareToLocationField)
    #       desc += ", compared to #{location.name} from #{compareField.label}"
    # desc

  applyToQuery: (query, filters) ->
    return @displayStrategy().applyToQuery(query, filters)

    # switch @display
    #   when 'simple'
    #     query.group_by = date_grouping
    #   when 'split'
    #     query.group_by = [date_grouping, @splitField]
    #   when 'compareToDate'
    #     query.group_by = date_grouping
    #     switch @compareToDate
    #       when 'previous_year'
    #         dateFilter = @getDateFilter filters
    #         if dateFilter
    #           since = moment(dateFilter.since).add(-1, 'years')
    #           query.since = since.format("YYYY-MM-DD")
    #       else
    #         throw "Unknown compare to value: #{@compareToDate}"
    #   when 'compareToLocation'
    #     query.group_by = date_grouping
    #     firstQuery = query
    #     secondQuery = _.cloneDeep firstQuery
    #     targetLocation = @getCompareToLocation(filters)
    #     if targetLocation
    #       secondQuery[@compareToLocationField] = targetLocation.id
    #       return [firstQuery, secondQuery]
    #   else
    #     throw "Unknown display: #{@display}"

  getSeries: (report, data) ->
    # series = switch @display
    #          when 'simple'
    #            @getSimpleSeries(data[0].events)
    #          when 'split'
    #            @getSplitSeries(report, data[0].events)
    #          when 'compareToDate'
    #            @getCompareToDateSeries(report, data[0].events)
    #          when 'compareToLocation'
    #            if data[1] && @getCompareToLocation(report.filters)
    #              @getCompareToLocationSeries(report, data[0].events, data[1].events)
    #            else
    #              @getSimpleSeries(data[0].events)
    #          else
    #            throw "Unknown display: #{@display}"
    @displayStrategy().getExtendedSeries(report, data)
    # series.interval = @grouping
    # @extendToDateBounds(report, series)
    # series.rows = @fillGaps series

    # series


  getCSV: (report, series) ->
    rows = []
    rows.push ["Date"].concat(series.cols)
    for row in series.rows
      rows.push _.map row, (v) -> if v then v else 0
    rows

  startRendering: (q) -> q.when(true)
