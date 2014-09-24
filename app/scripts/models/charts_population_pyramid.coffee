@Charts ?= {}

class @Charts.PopulationPyramid
  GENDERS = 'M': 'male', 'F': 'female'

  constructor: (fieldsCollection) ->
    @kind = 'PopulationPyramid'

  toJSON: ->
    @

  initializeFrom: (data) ->
    @

  isConfigurable: ->
    false

  applyToQuery: (query) ->
    query.group_by = ['age_group', 'gender']
    query.gender = _.keys GENDERS
    [query]

  getSeries: (report, data) ->
    data = data[0].events

    # convert the flat list of event counts to an array of objects, one for each age group
    groups = _.groupBy data, 'age_group'
    series = _.map groups, (items, age_group) ->
      group = _.object(_.map items, (item) -> [GENDERS[item.gender], item.count])
      group.age = age_group
      group

    _.sortBy series, (group) -> parseFloat(group.age.split('-')[0])

  getCSV: (report, series) ->
    rows = []
    rows.push ["Age", "Male", "Female"]
    for serie in series
      rows.push [serie.age, serie.male, serie.female]
    rows

