angular.module('ndApp')
  .factory 'Trendline', (Cdx, FieldsService) ->
    class Trendline
      constructor: ->
        @kind = 'Trendline'
        @display = 'simple'
        @splitField = 'gender'
        @grouping = 'year'

      getQuery: ->
        date_grouping = "#{@grouping}(created_at)"
        switch @display
          when 'simple'
            group_by: date_grouping
          when 'split'
            group_by: [date_grouping, @splitField]
          else
            throw "Uknknown display: #{@display}"

      getSeries: (data) ->
        switch @display
          when 'simple'
            @getSimpleSeries(data)
          when 'split'
            @getSplitSeries(data)
          else
            throw "Uknknown display: #{@display}"

      getSimpleSeries: (data) ->
        cols:
          ["Events"]
        rows:
          _.map data, (value) ->
            [value.created_at, value.count]

      getSplitSeries: (data) ->
        @sortData data

        options = FieldsService.optionsFor(@splitField)

        cols = _.map options, (option) -> option.label
        allValues = _.map options, (option) -> option.value

        rows = []

        i = 0
        len = data.length
        while i < len
          item = data[i]

          date = item.created_at
          row = [date]

          # Traverse all items that follow (including this one) as long
          # as their date is the same as this one
          j = i
          while j < len
            other_item = data[j]
            other_date = other_item.created_at
            if other_date != date
              break

            index = _.indexOf allValues, other_item[@splitField]
            row[index + 1] = other_item.count
            j += 1

          rows.push row
          i = j

        cols: cols, rows: rows

      sortData: (data) ->
        data.sort (x, y) =>
          if x.created_at < y.created_at
            -1
          else if x.created_at > y.created_at
            1
          else if x[@splitField] < y[@splitField]
            -1
          else if x[@splitField] > y[@splitField]
            1
          else
            0

      @deserialize: (data) ->
        chart = new Trendline
        chart.display = data.display
        chart.splitField = data.splitField
        chart.grouping = data.grouping
        chart
