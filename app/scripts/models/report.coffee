class @Report
  constructor: (fieldsCollection) ->
    @filters = []
    @charts  = []
    @fieldsCollection = () -> fieldsCollection

  addFilter: (filter) ->
    @filters.push filter
    filter

  addChart: (chart) ->
    @charts.push chart
    chart

  applyFiltersTo: (query) ->
    for filter in @filters
      filter.applyTo(query)
    query

  newQuery: ->
    page_size: 0
    assay_name: @assay

  closeQuery: (query) ->
    # If there's no result specified, restrict result to the valid values
    query.result ?= @fieldsCollection().find(FieldsCollection.fieldNames.result).values()

  fieldOptionsFor: (fieldName) ->
    @fieldsCollection().optionsFor(fieldName)

  duplicate: ->
    dup = new Report(@fieldsCollection())
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

    # TODO: we're missing the patient location in the filter description
    for filter in @filters when !filter.allSelected()
      switch filter.name
        when FieldsCollection.fieldNames.age_group then ageFilter = filter
        when FieldsCollection.fieldNames.date      then dateFilter = filter
        when FieldsCollection.fieldNames.ethnicity then ethnicityFilter = filter
        when FieldsCollection.fieldNames.gender    then genderFilter = filter
        when FieldsCollection.fieldNames.result    then resultFilter = filter
        when FieldsCollection.fieldNames.location  then locationFilter = filter
        else                                            otherFilters.push filter

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

      resolution = dateFilter.dateResolution()
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

  initializeFrom: (data) ->
    @id = data.id
    @name = data.name
    @description = data.description
    @assay = data.assay
    @filters = data.filters || []
    @charts = data.charts || []
    @

  toJSON: ->
    {
      id: @id
      name: @name
      description: @description
      assay: @assay
      filters: _.map @filters, (f) -> f.toJSON()
      charts: _.map @charts, (c) -> c.toJSON()
    }

