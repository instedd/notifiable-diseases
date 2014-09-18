@Charts ?= {}

class @Charts.PopulationPyramid
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
    query.gender = ['male', 'female']
    [query]

  getSeries: (report, data) ->
    data = data[0].events

    @sortData data

    # Build an array of objects with age, male and female properties
    series = []

    i = 0
    while i < data.length
      item = data[i]
      nextItem = data[i + 1]
      if item.age_group == nextItem?.age_group
        series.push age: item.age_group, male: item.count, female: nextItem.count
        i += 2
      else
        obj = age: item.age_group
        if item.gender == "male"
          item.male = item.count
          item.female = 0
        else
          item.female = item.count
          item.male = 0
        series.push obj
        i += 1

    series

  getCSV: (report, series) ->
    rows = []
    rows.push ["Age", "Male", "Female"]
    for serie in series
      rows.push [serie.age, serie.male, serie.female]
    rows

  sortData: (data) ->
    data.sort (x, y) =>
      if x.age_group < y.age_group
        -1
      else if x.age_group > y.age_group
        1
      else if x.gender < y.gender
        1
      else if x.gender > y.gender
        -1
      else
        0
