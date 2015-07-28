class Field
  constructor: (field, settings) ->
    @name = field.name
    @label = field.title
    @instructions = field.instructions
    @type ||= 'field'
    @searchable = field.searchable
    @searchable = true if field.searchable is "undefined" and not settings.onlySearchableFields

class EnumField extends Field
  constructor: (field, settings) ->
    @type = 'enum'
    @options = _.map field.enum, (value) ->
      label: field.values?[value].name || value
      value: value
    super(field)

  values: ->
    _.map @options, 'value'

  labels: ->
    _.map @options, 'label'

  labelFor: (value) ->
    _.find(@options, value: value)?.label

  @handles: (attrs) ->
    attrs.enum?

class ResultField extends EnumField
  constructor: (field, settings) ->
    super(field)
    @allOptions = @options
    @showPositive = settings.onlyShowPositiveResults
    @positive = _.filter @allOptions, (opt) -> opt.kind == 'positive'
    @valid = _.filter @allOptions, (opt) -> opt.kind != 'error'
    @options = if @showPositive then @positive else @valid

  validResults: () ->
    @valid

  positiveResults: () ->
    @positive

  results: () ->
    @options

  allResults: () ->
    @allOptions

  @handles: (attrs, name) ->
    name == FieldsCollection.fieldNames.result

class IntegerField extends Field
  constructor: (field, settings) ->
    @type = 'integer'
    @minimum = field.minimum
    @maximum = field.maximum
    super(field)

  @handles: (attrs) ->
    attrs.type == 'integer'

class LocationField extends Field
  constructor: (field, settings) ->
    @type = 'location'
    @locations = _.mapValues field.locations, (location, id) ->
      location.id = id
      location.label = location.name
      location
    @maxPolygonLevel = _.max(_.keys(settings.polygons[field.name]))
    settings.enableMapChart = true

    super(field)

  @handles: (attrs) ->
    attrs.locations?

  getLocation: (location_or_id) ->
    if !location_or_id?
      null
    else if typeof location_or_id is 'string'
      @locations[location_or_id]
    else
      location_or_id

  getParentLocations: (location_or_id) ->
    id = location_or_id
    parentLocations = []
    while true
      parentLocation = @getLocation(id)
      if parentLocation
        parentLocations.push parentLocation
        id = parentLocation.parent_id
        break unless id
      else
        break
    parentLocations.shift()
    parentLocations

  getFullLocationPath: (location) ->
    if location.parent_id && (parent = @locations[location.parent_id])
      "#{location.name}, #{@getFullLocationPath(parent)}"
    else
      location.name

  getMaxPolygonLevel: () ->
    @maxPolygonLevel


class RemoteLocationField extends Field
  constructor: (field, settings, injector) ->
    @type = 'location'
    @remote = true
    @locations = injector.get('RemoteLocationsServiceFactory').createService(field['location-service'])
    settings.enableMapChart = true
    super(field)

  @handles: (attrs) ->
    attrs['location-service']?

  getParentLocations: (location) ->
    location.ancestors or []

  getFullLocationPath: (location) ->
    name = location.name
    if location.ancestors and location.ancestors.length > 0
      ancestorsNames = _.pluck(location.ancestors, 'name')
      name += (" (" + ancestorsNames.reverse().join(", ") + ")")
    name

  getLocation: (location_or_id, opts={}) ->
    if !location_or_id?
      null
    else if typeof location_or_id is 'string'
      @locations.details(location_or_id, opts)[0]
    else
      location_or_id

  # TODO: This value should be obtained from the location service
  getMaxPolygonLevel: () -> 1


class DateField extends Field
  constructor: (field, settings) ->
    @resolution = field.resolution || "day"
    @type = 'date'
    super(field)

  @handles: (attrs) ->
    attrs.format == 'date-time'

  dateResolution: () ->
    @resolution


FIELD_TYPES = [ResultField, DateField, RemoteLocationField, LocationField, EnumField, IntegerField]

angular.module('ndApp')
  .service 'FieldsService', (Cdx, $q, settings, $injector) ->
    flattenProperties = (properties, flatten = {}, prefix = "") ->
      for name, field of properties
        if field.type == "object" and !field['location-service']
          flattenProperties(field.properties, flatten, "#{prefix}#{name}.")
        else if field.type == "array" and field.items.type == "object"
          flattenProperties(field.items.properties, flatten, "#{prefix}#{name}.")
        else
          flatten["#{prefix}#{name}"] = field
      flatten

    loadForContext: (context = {}) ->
      q = $q.defer()
      Cdx.fields(context).success (data) ->
        fields = flattenProperties(data.properties)

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
            field_type = _.find(FIELD_TYPES, (type) -> type.handles(field, name))
            if field_type
              field.name = name
              fields[name] = new field_type(field, settings, $injector)
            fields
          ), {}

        q.resolve(new FieldsCollection(fields))

      q.promise
