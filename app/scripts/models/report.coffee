class @Report
  constructor: (fieldsCollection, resource) ->
    @filters = []
    @charts  = []
    @resource = resource
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
    query = {page_size: 0}
    query[@mainField] = @mainValue
    query.resource = @resource
    query

  closeQuery: (query) ->
    # If there's no result specified, restrict result to the valid values
    resultFieldName = @fieldsCollection().names.result
    query.result ?= @fieldsCollection().find(resultFieldName).values()

  fieldOptionsFor: (fieldName) ->
    @fieldsCollection().optionsFor(fieldName)

  duplicate: ->
    dup = new Report(@fieldsCollection(), @resource)
    dup.name = "#{@name} (duplicate)"
    dup.description = @description
    dup.mainValue = @mainValue
    dup.mainField = @mainField
    dup.filters = @filters
    dup.charts = @charts
    dup

  fullDescription: ->
    if @filters.length == 0
      return "All #{@resourceTitle()}"

    # TODO: other filters is always empty for now, so it's not used
    otherFilters = []

    names = @fieldsCollection().names
    for filter in @filters when !filter.allSelected()
      switch filter.name
        when names.age_group        then ageFilter = filter
        when names.age              then ageFilter = filter
        when names.date             then dateFilter = filter
        when names.ethnicity        then ethnicityFilter = filter
        when names.gender           then genderFilter = filter
        when names.result           then resultFilter = filter
        when names.location         then locationFilter = filter
        when names.patient_location then patientLocationFilter = filter
        else                                              otherFilters.push filter

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
      str += "#{@resourceTitle()} "
    else
      str += " #{@resourceName()} "

    if resultFilter
      str += " of "
      str += resultFilter.shortDescription()
      str += " "

    if locationFilter
      str += " in "
      str += locationFilter.shortDescription()
      str += " "

    if patientLocationFilter
      str += " from patients in "
      str += patientLocationFilter.shortDescription()
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
    @mainField = data.mainField
    @mainValue = data.mainValue
    @resource = data.resource || 'tests' # Default option for backwards compatibility
    @filters = data.filters || []
    @charts = data.charts || []
    @

  resourceName: () ->
    @resource

  resourceTitle: () ->
    _.capitalize(@resourceName())

  toJSON: ->
    {
      id: @id
      name: @name
      description: @description
      mainValue: @mainValue
      mainField: @mainField
      resource: @resource
      filters: _.map @filters, (f) -> f.toJSON()
      charts: _.map @charts, (c) -> c.toJSON()
    }

