@Charts ?= {}

class @Charts.PopulationPyramid
  GENDERS = 'M': 'male', 'F': 'female'

  constructor: (fieldsCollection) ->
    @kind = 'PopulationPyramid'
    age_group_field = fieldsCollection.find(FieldsCollection.fieldNames.age) || fieldsCollection.find(FieldsCollection.fieldNames.age_group)
    @ageGroupField = () -> age_group_field

  toJSON: ->
    @

  initializeFrom: (data) ->
    @

  isConfigurable: ->
    false

  applyToQuery: (query) ->
    if @ageGroupField().name == FieldsCollection.fieldNames.age_group
      age_grouping = FieldsCollection.fieldNames.age_group
    else
      age_grouping = {}
      age_grouping[@ageGroupField().name] = [[0,0.5], [0.5,2], [2,4], [5,8], [9,17], [18,24], [25,49], [50,64], [65,74], [75,84], [85, null]]

    query.group_by = [age_grouping, FieldsCollection.fieldNames.gender]
    [query]

  getFilter: (report) ->
    _.find report.filters, name: @ageGroupField().name

  getSeries: (report, data) ->
    data = data[0].events
    field = @ageGroupField()
    if !field
      # convert the flat list of event counts to an array of objects, one for each age group
      groups = _.groupBy data, FieldsCollection.fieldNames.age
      series = _.map groups, (items, age_group) ->
        group = _.object(_.map items, (item) -> [(GENDERS[item.gender] || item.gender), item.count])
        group.age = age_group
        group
    else
      options = if @ageGroupField().name == FieldsCollection.fieldNames.age
        [[0,0.5], [0.5,2], [2,4], [5,8], [9,17], [18,24], [25,49], [50,64], [65,74], [75,84], "85+"]
      else if filter = @getFilter(report)
        filter.values
      else
        _.map field.options, 'value'

      # create the age groups from the age_group enumerated options and then
      # fill in the counts with the received data
      groups = _.object(_.map options, (option) ->
        [option, { age: option, male: 0, female: 0}]
      )
      _.forEach data, (item) =>
        groups[item[@ageGroupField().name]][GENDERS[item.gender] || item.gender] = item.count if groups[item[@ageGroupField().name]]
      series = _.mapValues groups

    _.sortBy series, (group) => parseFloat(@splitIfNecessary(group.age)[0])

  splitIfNecessary: (age) ->
    if age.split?
      age.split('-')
    else
      age

  getCSV: (report, series) ->
    rows = []
    rows.push ["Age", "Male", "Female"]
    for serie in series
      rows.push [serie.age, serie.male, serie.female]
    rows

  startRendering: (q) -> q.when(true)
