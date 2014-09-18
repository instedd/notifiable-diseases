class @FieldsCollection
  constructor: (@fields) ->

  @fieldNames:
    age_group: 'age_group'
    date: 'start_time'
    ethnicity: 'race_ethnicity'
    gender: 'gender'
    result: 'result'
    assay_name: 'assay_name'
    location: 'location'

  all: ->
    _.values @fields

  allEnum: ->
    enumFields = _.filter @fields, type: 'enum'
    _.sortBy enumFields, (f) -> f.label.toLowerCase()

  find: (name) ->
    @fields[name]

  optionsFor: (name) ->
    @fields[name].options

  locationFor: (name, id) ->
    @fields[name].locations[id.toString()]

  getParentLocations: (name, id) ->
    id = id.toString()

    parentLocations = []
    while true
      parentLocation = @locationFor(name, id)
      if parentLocation
        parentLocations.push parentLocation
        id = parentLocation.parent_id
        break unless id
      else
        break
    parentLocations.shift()
    # parentLocations.reverse()
    parentLocations

  datePeriods: ->
    resolution = @fields[FieldsCollection.fieldNames.date].dateResolution()

    has_day   =                resolution == "day"
    has_week  = has_day     || resolution == "week"
    has_month = has_week    || resolution == "month"
    has_year  = has_month   || resolution == "year"

    periods = []
    periods.push value: "day",   label: "Day"   if has_day
    periods.push value: "week",  label: "Week"  if has_week
    periods.push value: "month", label: "Month" if has_month
    periods.push value: "year",  label: "Year"  if has_year
    periods

