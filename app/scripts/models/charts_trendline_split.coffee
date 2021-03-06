@Charts ?= {}

class @Charts.Trendline.SplitDisplay extends @Charts.Trendline.BaseDisplay

  constructor: (t) ->
    super(t)
    @splitField = t.splitField

  description: () ->
    splitField = @fieldsCollection().find(@splitField)
    "#{super()}, split by #{splitField?.label.toLowerCase()}, stacked"

  applyToQuery: (query, filters) ->
    query.group_by = [@dateGrouping, @splitField]
    if @values == 'percentage'
      denominator = @denominatorFor(query)
      denominator.group_by = @dateGrouping
      [@numeratorFor(query), denominator]
    else
      [query]

  getSeries: (report, data) ->
    datapoints = if @values == 'percentage' and data.length > 0
      positives = @sortSplitData data[0][@resource]
      denominators = @sortSplitData data[1][@resource]
      @getRates(positives, denominators)
    else
      @sortSplitData data[0][@resource]

    @getSplitSeries(report, datapoints)

  getSplitSeries: (report, data) ->
    options = report.fieldOptionsFor(@splitField)

    cols = _.map options, (option) -> option.label
    allValues = _.map options, (option) -> option.value

    # Check which column indices we found: this basically tells
    # us which columns have values in the results, so later we
    # can discard those that have no values.
    foundIndices = []

    rows = []

    i = 0
    len = data.length
    while i < len
      item = data[i]

      date = item[@timeField]
      row = [date]

      # Traverse all items that follow (including this one) as long
      # as their date is the same as this one
      j = i
      while j < len
        other_item = data[j]
        other_date = other_item[@timeField]
        if other_date != date
          break

        index = _.indexOf allValues, other_item[@splitField]

        # This is a sanity check: the index shouldn't be -1 if all data is correct
        if index != -1
          foundIndices[index] = true
          row[index + 1] = other_item.rate || other_item.count

        j += 1

      rows.push row
      i = j

    # Convert the indices to numbers
    indices = []
    for i in [0 ... foundIndices.length]
      indices.push i if foundIndices[i]
    foundIndices = indices

    # Build new rows with only indices for the found indices
    newRows = []
    for row in rows
      newRow = []
      newRow.push row[0]
      for index in foundIndices
        newRow.push row[index + 1]
      newRows.push newRow

    # The same goes for the cols
    newCols = []
    for index in foundIndices
      newCols.push cols[index]

    cols: newCols, rows: newRows, indices: foundIndices


  sortSplitData: (data) ->
    data.sort (x, y) =>
      if x[@timeField] < y[@timeField]
        -1
      else if x[@timeField] > y[@timeField]
        1
      else if x[@splitField] < y[@splitField]
        -1
      else if x[@splitField] > y[@splitField]
        1
      else
        0
