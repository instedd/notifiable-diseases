@Charts ?= {}

class @Charts.PopulationPyramid
  GENDERS = 'M': 'male', 'F': 'female'

  constructor: (fieldsCollection) ->
    @kind = 'PopulationPyramid'
    @ageGroupField = fieldsCollection.age_field() || fieldsCollection.age_group_field()
    @validResults = _.map fieldsCollection.result_field().validResults(), 'value'
    @values = 'count'
    @

  toJSON: ->
    @

  initializeFrom: (data) ->
    @values = data.values
    @

  isConfigurable: ->
    true

  applyToQuery: (query) ->
    if @ageGroupField.name == FieldsCollection.fieldNames.age_group
      age_grouping = FieldsCollection.fieldNames.age_group
    else
      age_grouping = {}
      age_grouping[@ageGroupField.name] = [[0,0.5], [0.5,2], [2,4], [5,8], [9,17], [18,24], [25,49], [50,64], [65,74], [75,84], [85, null]]

    query.group_by = [age_grouping, FieldsCollection.fieldNames.gender]

    if @values == 'percentage'
      denominator = _.cloneDeep query
      denominator.result = @validResults
      [query, denominator]
    else
      [query]

  getFilter: (report) ->
    _.find report.filters, name: @ageGroupField.name

  getSeries: (report, datas) ->
    data = datas[0].events
    field = @ageGroupField
    if !field
      # Convert the flat list of event counts to an array of objects, one for each age group
      # TODO: Support percentage with non-age-group field
      groups = _.groupBy data, FieldsCollection.fieldNames.age
      series = _.map groups, (items, age_group) ->
        group = _.object(_.map items, (item) -> [(GENDERS[item.gender] || item.gender), item.count])
        group.age = age_group
        group
    else
      options = if @ageGroupField.name == FieldsCollection.fieldNames.age
        [[0,0.5], [0.5,2], [2,4], [5,8], [9,17], [18,24], [25,49], [50,64], [65,74], [75,84], "85+"]
      else if filter = @getFilter(report)
        filter.values
      else
        _.map field.options, 'value'

      # create the age groups from the age_group enumerated options and then
      # fill in the counts with the received data
      groups = _.object(_.map options, (option) ->
        [option, { age: option, male: { value: 0 }, female: { value: 0 } }]
      )

      _.forEach data, (item) =>
        [age, gender] = @ageGenderFor(item)
        if groups[age] and groups[age][gender]
          groups[age][gender].count = item.count
          groups[age][gender].value = item.count

      # Set denominators for all counts
      if @values == 'percentage' and datas[1]
        _.forEach datas[1].events, (item) =>
          [age, gender] = @ageGenderFor(item)
          if groups[age] and groups[age][gender] and item.count > 0
            groups[age][gender].value /= item.count
            groups[age][gender].total =  item.count

      series = _.mapValues groups

    _.sortBy series, (group) => parseFloat(@splitIfNecessary(group.age)[0])

  ageGenderFor: (item) =>
    [item[@ageGroupField.name], GENDERS[item.gender] || item.gender]

  splitIfNecessary: (age) ->
    if age.split?
      age.split('-')
    else
      age

  getCSV: (report, series) ->
    rows = []

    if @values == 'percentage'
      rows.push ["Age", "Male positive", "Male total", "Female positive", "Female total"]
      for serie in series
        console.log serie
        rows.push [serie.age, serie.male.count || 0, serie.male.total || 0, serie.female.count || 0, serie.female.total || 0]

    else
      rows.push ["Age", "Male positive", "Female positive"]
      for serie in series
        console.log serie
        rows.push [serie.age, serie.male.count || 0, serie.female.count || 0]

    rows

  startRendering: (q) -> q.when(true)
