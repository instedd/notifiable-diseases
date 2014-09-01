angular.module('ndApp')
  .factory 'Trendline', (Cdx, FieldsService) ->
    class Trendline
      constructor: ->
        @kind = 'Trendline'
        @display = 'simple'
        @grouping = 'year'
        @compareToDate = 'previous_year'

      initializeNew: ->
        @splitField = FieldsService.allEnum()[0].name

      @deserialize: (data) ->
        chart = new Trendline
        chart.display = data.display
        chart.splitField = data.splitField
        chart.grouping = data.grouping
        chart.compareToDate = data.compareToDate
        chart.compareToLocation = data.compareToLocation
        chart

      isConfigurable: ->
        true

      vizType: ->
        switch @display
          when 'compareToDate', 'compareToLocation'
            'LineChart'
          else
            'AreaChart'

      isStacked: ->
        @display != 'compareToDate'

      description: (report) ->
        desc = "Events grouped by #{@grouping}"
        switch @display
          when 'split'
            desc += ", split by #{FieldsService.labelFor(@splitField).toLowerCase()}"
          when 'compareToDate'
            switch @compareToDate
              when 'previous_year'
                desc += ", compared to previous year"
              else
                throw "Unknown compare to value: #{@compareToDate}"
          when 'compareToLocation'
            location = @getCompareToLocation(report.filters)
            if location
              desc += ", compared to #{location.name}"
        desc

      applyToQuery: (query, filters) ->
        date_grouping = "#{@grouping}(started_at)"
        switch @display
          when 'simple'
            query.group_by = date_grouping
          when 'split'
            query.group_by = [date_grouping, @splitField]
          when 'compareToDate'
            query.group_by = date_grouping
            switch @compareToDate
              when 'previous_year'
                dateFilter = @getDateFilter filters
                if dateFilter
                  since = moment(dateFilter.since).add(-1, 'years')
                  query.since = since.format("YYYY-MM-DD")
              else
                throw "Unknown compare to value: #{@compareToDate}"
          when 'compareToLocation'
            query.group_by = date_grouping
            firstQuery = query
            secondQuery = JSON.parse(JSON.stringify(firstQuery))
            targetLocation = @getCompareToLocation(filters)
            if targetLocation
              secondQuery.location = targetLocation.id
              return [firstQuery, secondQuery]
          else
            throw "Uknknown display: #{@display}"

        [query]

      getSeries: (report, data) ->
        series = switch @display
                 when 'simple'
                   @getSimpleSeries(data[0].events)
                 when 'split'
                   @getSplitSeries(report, data[0].events)
                 when 'compareToDate'
                   @getCompareToDateSeries(report, data[0].events)
                 when 'compareToLocation'
                   if @getCompareToLocation(report.filters)
                     @getCompareToLocationSeries(report, data[0].events, data[1].events)
                   else
                     @getSimpleSeries(data[0].events)
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

      getCompareToDateSeries: (report, data) ->
        @sortData data

        # First, index data by started_at
        indexedData = {}
        for event in data
          indexedData[event.started_at] = event.count

        # Now check if there's a date filter. If so, we
        # will skip rows until we are after the "since" date.
        since = @getDateFilter(report.filters)?.since
        since = moment(since) if since

        if data.length > 0
          max = data[data.length - 1].started_at

        # Next, for each event we create two results, one for the
        # previous year and one for the current one
        rows = []
        for event in data
          date = event.started_at
          switch @grouping
            when "day"
              currentDate = moment(date)
              previousDate = moment(currentDate).add(-1, 'years').format("YYYY-MM-DD")
              nextDate = moment(currentDate).add(1, 'years').format("YYYY-MM-DD")
            when "week"
              currentDate = moment(date)
              previousDate = moment(currentDate).add(-1, 'years').format("gggg-[W]WW")
              nextDate = moment(currentDate).add(1, 'years').format("gggg-[W]WW")
            when "month"
              currentDate = moment("#{date}-01")
              previousDate = moment(currentDate).add(-1, 'years').format("YYYY-MM")
              nextDate = moment(currentDate).add(1, 'years').format("YYYY-MM")
            when "year"
              currentDate = moment("#{date}-01-01")
              previousDate = (parseInt(date) - 1).toString()
              nextDate = (parseInt(date) + 1).toString()

          # If we are still behind the "since" date, skip this event
          if since && currentDate.diff(since) < 0
            continue

          previousYearCount = indexedData[previousDate]
          previousYearCount ?= 0

          rows.push [date, event.count, previousYearCount]

          # We also need to check the next year: if there's no data
          # we fill it with this year's value, but only if it's before
          # the maximum date from the results.
          if nextDate <= max
            nextYearCount = indexedData[nextDate]
            unless nextYearCount
              rows.push [nextDate, 0, event.count]

        rows.sort (x, y) ->
          if x[0] < y[0]
            -1
          else if x[0] > y[0]
            1
          else
            0

        cols:
          ["Events", "Previous year events"]
        rows:
          rows

      getCompareToLocationSeries: (report, thisLocationEvents, otherLocationEvents) ->
        @sortData thisLocationEvents
        @sortData otherLocationEvents

        rows = []

        # Traverse both lists at the same time, always advancing the one
        # that has the lowest started_at value (similar to a merge sort).
        thisIndex = 0
        otherIndex = 0

        while true
          thisData = thisLocationEvents[thisIndex]
          otherData = otherLocationEvents[otherIndex]

          if !thisData && !otherData
            break

          if thisData && !otherData
            rows.push [thisData.started_at, thisData.count, 0]
            thisIndex += 1
          else if otherData && !thisData
            rows.push [otherData.started_at, 0, otherData.count]
            otherIndex += 1
          else
            thisStartedAt = thisData.started_at
            otherStartedAt = otherData.started_at

            if thisStartedAt == otherStartedAt
              rows.push [thisData.started_at, thisData.count, otherData.count]
              thisIndex += 1
              otherIndex += 1
            else if thisStartedAt < otherStartedAt
              rows.push [thisData.started_at, thisData.count, 0]
              thisIndex += 1
            else #  thisStartedAt > otherStartedAt
              rows.push [otherData.started_at, 0, otherData.count]
              otherIndex += 1

        filterLocation = @getFilterLocation(report.filters)
        targetLocation = @getCompareToLocation(report.filters)

        cols:
          ["#{filterLocation.name} events", "#{targetLocation.name} events"]
        rows:
          rows

      getFilterLocation: (filters) ->
        locationFilter = _.find filters, (filter) -> filter.name == "location"
        locationId = locationFilter.location.id
        FieldsService.locationFor "location", locationId

      getCompareToLocation: (filters) ->
        locationFilter = _.find filters, (filter) -> filter.name == "location"
        locationId = locationFilter?.location?.id
        if locationId
          parentLocations = FieldsService.getParentLocations "location", locationId
          myLevel = parseInt(@compareToLocation)
          _.find parentLocations, (loc) -> loc.level == myLevel
        else
          null

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

      getDateFilter: (filters) ->
        _.find filters, (filter) -> filter.name == "date"
