class Field
  constructor: (field) ->
    @name = field.name
    @type = field.type
    @label = field.label
    @instructions = field.instructions

class EnumField extends Field
  constructor: (field) ->
    @options = field.valid_values.options
    super(field)

  values: ->
    _.map @options, 'value'

  labels: ->
    _.map @options, 'label'

  labelFor: (value) ->
    _.find(@options, value: value)?.label

appendFlattenedLocations = (locations, all) ->
  locations = _.sortBy locations, (location) -> location.name.toLowerCase()
  for location in locations
    all.push location
    appendFlattenedLocations location.children, all
  all

class LocationField extends Field
  constructor: (field) ->
    @byId = {}

    roots = field.valid_values.locations
    flattenedLocations = appendFlattenedLocations roots, []
    for location in flattenedLocations
      @byId[location.id] = location

    super(field)

  flattenedLocations: () ->
    _.values @byId

  getFullLocationPath: (location) ->
    if location.parent_id && (parent = @byId[location.parent_id])
      "#{location.name}, #{@getFullLocationPath(parent)}"
    else
      location.name

class DateField extends Field
  constructor: (field) ->
    @resolution = field.valid_values?.resolution || "day"
    super(field)

  dateResolution: () ->
    @resolution

FIELD_TYPE_MAPPINGS =
  date: DateField
  enum: EnumField
  location: LocationField


angular.module('ndApp')
  .service 'FieldsService', (Cdx, $q) ->
    loadForContext: (context = {}) ->
      q = $q.defer()
      Cdx.fields(context).success (data) ->
        fields = _.zipObject _.map(data, (field) -> [field.name, field])

        # Keep only positive results
        resultField = fields['result']
        if resultField
          resultField.valid_values.options = _.select resultField.valid_values.options, (option) -> option.kind == "positive"

        fields["age_group"]?.instructions = "Select the age groups of the events you want to filter"
        fields["date"]?.instructions = "Select the date range of the events you want to filter"
        fields["ethnicity"]?.instructions = "Select the ethnicities of the events you want to filter"
        fields["gender"]?.instructions = "Select the genders of the events you want to filter"
        fields["result"]?.instructions = "Select the results of the events you want to filter"

        fields = _.mapValues fields, (field) ->
          field_type = FIELD_TYPE_MAPPINGS[field.type] || Field
          new field_type(field)

        q.resolve(new FieldsCollection(fields))
      q.promise

