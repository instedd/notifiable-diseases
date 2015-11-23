class @FieldsCollection

  constructor: (@fields, @names, @filtersWhitelist) ->
    _.each @names, (value, key) =>
      @[key + '_field'] = () => @find(value)

  all: ->
    _.values @fields

  allEnum: ->
    enumFields = _.filter @fields, type: 'enum'
    _.sortBy enumFields, (f) -> f.label.toLowerCase()

  allLocation: ->
    _.filter @fields, type: 'location'

  find: (name) ->
    @fields[name]

  filterFields: ->
    filtereableFields = _.reject @fields, (field) =>
      field.searchable == false or (field.type == 'enum' && field.options.length <= 1) or
        (@filtersWhitelist != null and not _.includes(@filtersWhitelist, field.name))
    _.sortBy filtereableFields, (f) -> f.label.toLowerCase()

  multiValuedEnums: ->
    _.filter @allEnum(), (field) -> field.options.length > 1

  optionsFor: (name) ->
    @fields[name].options

  # Used by trendline
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
    resolution = @fields[@names.date].dateResolution()

    has_day   =                resolution == "day" || resolution == "hour" || resolution == "minute" || resolution == "second"
    has_week  = has_day     || resolution == "week"
    has_month = has_week    || resolution == "month"
    has_year  = has_month   || resolution == "year"

    periods = []
    periods.push value: "day",   label: "Day"   if has_day
    periods.push value: "week",  label: "Week"  if has_week
    periods.push value: "month", label: "Month" if has_month
    periods.push value: "year",  label: "Year"  if has_year
    periods

