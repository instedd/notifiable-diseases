class Field
  constructor: (field) ->
    @name = field.name
    @label = field.title
    @instructions = field.instructions
    @type ||= 'field'

class EnumField extends Field
  constructor: (field) ->
    @type = 'enum'
    @options = _.map field.values, (option, value) ->
      option.value = value
      option.label = option.name
      option
    super(field)

  values: ->
    _.map @options, 'value'

  labels: ->
    _.map @options, 'label'

  labelFor: (value) ->
    _.find(@options, value: value)?.label

  @handles: (attrs) ->
    attrs.values?

class LocationField extends Field
  constructor: (field) ->
    @type = 'location'
    @locations = _.mapValues field.locations, (location, id) ->
      location.id = id
      location.label = location.name
      location

    super(field)

  @handles: (attrs) ->
    attrs.locations?

  getFullLocationPath: (location) ->
    if location.parent_id && (parent = @locations[location.parent_id])
      "#{location.name}, #{@getFullLocationPath(parent)}"
    else
      location.name

class DateField extends Field
  constructor: (field) ->
    @resolution = field.resolution || "day"
    @type = 'date'
    super(field)

  @handles: (attrs) ->
    attrs.format == 'date-time'

  dateResolution: () ->
    @resolution


FIELD_TYPES = [DateField, LocationField, EnumField]

angular.module('ndApp')
  .service 'FieldsService', (Cdx, $q) ->
    loadForContext: (context = {}) ->
      q = $q.defer()
      Cdx.fields(context).success (data) ->
        fields = data.properties

        # Keep only positive results
        resultField = fields[FieldsCollection.fieldNames.result]
        if resultField
          resultField.values = _.pick resultField.values, (option) -> option.kind == "positive"
          resultField.enum = resultField.values.keys

        # Add instructions for known fields
        fields[FieldsCollection.fieldNames.age_group]?.instructions = "Select the age groups of the events you want to filter"
        fields[FieldsCollection.fieldNames.date]?.instructions = "Select the date range of the events you want to filter"
        fields[FieldsCollection.fieldNames.ethnicity]?.instructions = "Select the ethnicities of the events you want to filter"
        fields[FieldsCollection.fieldNames.gender]?.instructions = "Select the genders of the events you want to filter"
        fields[FieldsCollection.fieldNames.result]?.instructions = "Select the results of the events you want to filter"

        # fields = _.mapValues fields, (field, name) ->
        #   field.name = name
        #   field_type = _.find(FIELD_TYPES, (type) -> type.handles(field)) || Field
        #   new field_type(field)

        # Not supported field types are ignored.
        fields = _.inject fields, ((fields, field, name) ->
            field_type = _.find(FIELD_TYPES, (type) -> type.handles(field))
            if field_type
              field.name = name
              fields[name] = new field_type(field)
            fields
          ), {}

        q.resolve(new FieldsCollection(fields))

      q.promise
