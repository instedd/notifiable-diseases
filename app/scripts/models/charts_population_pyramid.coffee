@Charts ?= {}

class @Charts.PopulationPyramid extends @Charts.Base
  AGE_GROUPS = ["..6mo", "6mo..2y", "2y..4y", "5y..8y", "9y..17y", "18y..24y", "25y..49y", "50y..64y", "65y..74y", "75y..84y", "85y.."]

  constructor: (fieldsCollection) ->
    super(fieldsCollection)
    @kind = 'PopulationPyramid'
    @ageField = fieldsCollection.age_field()
    @genderField = fieldsCollection.gender_field()
    @values = 'count'

  toJSON: ->
    @

  initializeFrom: (data) ->
    @values = data.values
    @

  isConfigurable: ->
    true

  applyToQuery: (query) ->
    age_grouping = {}
    age_grouping[@ageField.name] = AGE_GROUPS
    query.group_by = [age_grouping, FieldsCollection.fieldNames.gender]
    if @values == 'percentage' then [@numeratorFor(query), @denominatorFor(query)] else [query]

  getFilter: (report) ->
    _.find report.filters, name: @ageField.name

  getSeries: (report, datas) ->
    data = datas[0].tests
    field = @ageField

    # create the age groups from the age_group enumerated options and then
    # fill in the counts with the received data
    groups = _.object(_.map AGE_GROUPS, (option) ->
      [option, { age: option, male: { value: 0 }, female: { value: 0 } }]
    )

    _.forEach data, (item) =>
      [age, gender] = @ageGenderFor(item)
      if groups[age] and groups[age][gender]
        groups[age][gender].count = item.count
        groups[age][gender].value = item.count

    # Set denominators for all counts
    if @values == 'percentage' and datas[1]
      _.forEach datas[1].tests, (item) =>
        [age, gender] = @ageGenderFor(item)
        if groups[age] and groups[age][gender] and item.count > 0
          groups[age][gender].value /= item.count
          groups[age][gender].total =  item.count

    _.map AGE_GROUPS, (group) -> groups[group]

  ageGenderFor: (item) =>
    [item[@ageField.name], item[@genderField.name]]

  getCSV: (report, series) ->
    rows = []

    if @values == 'percentage'
      rows.push ["Age", "Male positive", "Male total", "Female positive", "Female total"]
      for serie in series
        rows.push [serie.age, serie.male.count || 0, serie.male.total || 0, serie.female.count || 0, serie.female.total || 0]

    else
      rows.push ["Age", "Male positive", "Female positive"]
      for serie in series
        rows.push [serie.age, serie.male.count || 0, serie.female.count || 0]

    rows

  startRendering: (q) -> q.when(true)
