angular.module('ndApp')
  .factory 'Report', (FiltersService, FieldsService, ChartsService) ->
    class Report
      constructor: ->
        @filters = []
        @charts  = []

      createFilter: (name) ->
        filter = FiltersService.create name
        filter.setReport?(this)
        @filters.push filter
        filter

      applyFiltersTo: (query) ->
        for filter in @filters
          filter.applyTo(query)
        query

      newQuery: ->
        page_size: 0
        assay_name: @assay

      closeQuery: (query) ->
        # If there's no result specified, restrict result to the valid values
        query.result ?= FieldsService.valuesFor("result")

      fieldOptionsFor: (fieldName) ->
        FieldsService.optionsFor(fieldName)

      duplicate: ->
        dup = new Report
        dup.name = "#{@name} (duplicate)"
        dup.description = @description
        dup.assay = @assay
        dup.filters = @filters
        dup.charts = @charts
        dup

      fullDescription: ->
        if @filters.length == 0
          return "All cases"

        # TODO: other filters is always empty for now, so it's not used
        otherFilters = []

        for filter in @filters when !filter.allSelected()
          switch filter.name
            when "age_group" then ageFilter = filter
            when "date"      then dateFilter = filter
            when "ethnicity" then ethnicityFilter = filter
            when "gender"    then genderFilter = filter
            when "result"    then resultFilter = filter
            when "location"  then locationFilter = filter
            else                  otherFilters.push filter

        str = ""
        first = true

        if ageFilter
          str += ageFilter.shortDescription(first)
          first = false

        if genderFilter
          str += ", " unless first
          str += genderFilter.shortDescription(first)
          first = false

        if ethnicityFilter
          str += ", " unless first
          str += ethnicityFilter.shortDescription(first)
          first = false

        if str.length == 0
          str += "Cases "
        else
          str += " cases "

        if resultFilter
          str += " of "
          str += resultFilter.shortDescription()
          str += " "

        if locationFilter
          str += " in "
          str += locationFilter.shortDescription()
          str += " "

        if dateFilter
          str += " occurred between "

          resolution = FieldsService.dateResolution()
          sinceDate = moment(dateFilter.since)
          untilDate = moment(dateFilter.until)

          switch resolution
            when "day"
              str += "#{dateFilter.since} and #{dateFilter.until}"
            when "week"
              str += "#{sinceDate.format('YYYY-[W]WW')} and #{untilDate.format('YYYY-[W]WW')}"
            when "month"
              str += "#{sinceDate.format('YYYY-MM')} and #{untilDate.format('YYYY-MM')}"
            when "year"
              str += "#{sinceDate.year()} and #{untilDate.year()}"

        str

      findFilter: (name) ->
        _.find @filters, (filter) -> filter.name == name

      @deserialize: (data) ->
        report = new Report
        report.id = data.id
        report.name = data.name
        report.description = data.description
        report.assay = data.assay
        report.filters = _.map data.filters, (filter) ->
          FiltersService.deserialize(filter)
        report.charts = _.map data.charts, (chart) ->
          ChartsService.deserialize(chart)
        report

