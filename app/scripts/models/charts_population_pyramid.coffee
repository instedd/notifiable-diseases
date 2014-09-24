@Charts ?= {}

class @Charts.PopulationPyramid
  GENDERS = 'M': 'male', 'F': 'female'

  constructor: (fieldsCollection) ->
    @kind = 'PopulationPyramid'
    age_group_field = fieldsCollection.find(FieldsCollection.fieldNames.age_group)
    @ageGroupField = () -> age_group_field

  toJSON: ->
    @

  initializeFrom: (data) ->
    @

  isConfigurable: ->
    false

  applyToQuery: (query) ->
    query.group_by = [FieldsCollection.fieldNames.age_group, FieldsCollection.fieldNames.gender]
    [query]

  getFilter = (report) ->
    _.find report.filters, name: FieldsCollection.fieldNames.age_group

  getSeries: (report, data) ->
    data = data[0].events

    field = @ageGroupField()
    if !field
      # convert the flat list of event counts to an array of objects, one for each age group
      groups = _.groupBy data, FieldsCollection.fieldNames.age_group
      series = _.map groups, (items, age_group) ->
        group = _.object(_.map items, (item) -> [GENDERS[item.gender], item.count])
        group.age = age_group
        group
    else
      options = if filter = getFilter(report)
        filter.values
      else
        _.map field.options, 'value'

      # create the age groups from the age_group enumerated options and then
      # fill in the counts with the received data
      groups = _.object(_.map options, (option) ->
        [option, { age: option, male: 0, female: 0}]
      )
      _.forEach data, (item) ->
        groups[item.age_group][GENDERS[item.gender]] = item.count if groups[item.age_group]
      series = _.mapValues groups

    _.sortBy series, (group) -> parseFloat(group.age.split('-')[0])

  getCSV: (report, series) ->
    rows = []
    rows.push ["Age", "Male", "Female"]
    for serie in series
      rows.push [serie.age, serie.male, serie.female]
    rows

  startRendering: (q) -> q.when(true)
