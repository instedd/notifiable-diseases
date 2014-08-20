angular.module('ndApp')
  .factory 'Trendline', (Cdx, FieldsService) ->
    class Trendline
      constructor: ->
        @kind = 'Trendline'
        @display = 'simple'
        @grouping = 'year'
        @splitField = FieldsService.allEnum()[0].name

      @deserialize: (data) ->
        chart = new Trendline
        chart.display = data.display
        chart.splitField = data.splitField
        chart.grouping = data.grouping
        chart

      isConfigurable: ->
        true

      description: ->
        desc = "Events grouped by #{@grouping}"
        if @display == 'split'
          desc += ", split by #{FieldsService.labelFor(@splitField).toLowerCase()}"
        desc

      applyToQuery: (query) ->
        date_grouping = "#{@grouping}(started_at)"
        switch @display
          when 'simple'
            query.group_by = date_grouping
          when 'split'
            query.group_by = [date_grouping, @splitField]
          else
            throw "Uknknown display: #{@display}"

      getSeries: (report, data) ->
        data = data.events
        series = switch @display
                 when 'simple'
                   @getSimpleSeries(data)
                 when 'split'
                   @getSplitSeries(report, data)
                 else
                   throw "Uknknown display: #{@display}"
        series.interval = @grouping
        series

      getSimpleSeries: (data) ->
        @sortData data

        cols:
          ["Events"]
        rows:
          _.map data, (value) ->
            [value.started_at, value.count]

      getSplitSeries: (report, data) ->
        @sortSplitData data

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

          date = item.started_at
          row = [date]

          # Traverse all items that follow (including this one) as long
          # as their date is the same as this one
          j = i
          while j < len
            other_item = data[j]
            other_date = other_item.started_at
            if other_date != date
              break

            index = _.indexOf allValues, other_item[@splitField]

            # This is a sanity check: the index shouldn't be -1 if all data is correct
            if index != -1
              foundIndices[index] = true
              row[index + 1] = other_item.count

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

      getCSV: (series) ->
        rows = []
        rows.push ["Date"].concat(series.cols)
        for row in series.rows
          rows.push _.map row, (v) -> if v then v else 0
        rows

      sortData: (data) ->
        data.sort (x, y) =>
          if x.started_at < y.started_at
            -1
          else if x.started_at > y.started_at
            1
          else
            0

      sortSplitData: (data) ->
        data.sort (x, y) =>
          if x.started_at < y.started_at
            -1
          else if x.started_at > y.started_at
            1
          else if x[@splitField] < y[@splitField]
            -1
          else if x[@splitField] > y[@splitField]
            1
          else
            0
