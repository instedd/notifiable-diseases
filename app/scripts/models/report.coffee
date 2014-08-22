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

        for filter in @filters when !filter.empty()
          switch filter.name
            when "age_group" then ageFilter = filter
            when "date"      then dateFilter = filter
            when "ethnicity" then ethnicityFilter = filter
            when "gender"    then genderFilter = filter
            when "result"    then resultFilter = filter
            else                  otherFilters.push filter

        str = ""

        if ageFilter
          str += ageFilter.shortDescription()

        if genderFilter
          str += ", " unless str.length == 0
          str += genderFilter.shortDescription()

        if ethnicityFilter
          str += ", " unless str.length == 0
          str += ethnicityFilter.shortDescription()

        if str.length == 0
          str += "Cases "
        else
          str += " cases "

        if resultFilter
          str += " of "
          str += resultFilter.shortDescription()
          str += " "

        if dateFilter
          str += "occurred between #{dateFilter.since} and #{dateFilter.until}"

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

