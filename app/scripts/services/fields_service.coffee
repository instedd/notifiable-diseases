angular.module('ndApp')
  .service 'FieldsService', (Cdx, $q, settings, $injector) ->
    buildProperties = (properties, names, fields = {}, prefix = "") ->
      for name, field of properties
        field.name = "#{prefix}#{name}"
        fieldType = _.find(FieldTypes, (type) -> type.handles(field, field.name, names))
        if fieldType
          fields[field.name] = new fieldType(field, settings, $injector)
        else if field.type == "object"
          buildProperties(field.properties, names, fields, "#{field.name}.")
        else if field.type == "array" and field.items.type == "object"
          buildProperties(field.items.properties, names, fields, "#{field.name}.")
      fields

    nameFor: (resource, key) ->
      settings.knownFields[resource][key]

    namesFor: (resource) ->
      settings.knownFields[resource]

    loadForContext: (resource, context = {}) ->
      q = $q.defer()
      Cdx.fields(resource, context).success (data) =>
        fields = buildProperties(data.properties, @namesFor(resource))

        # Add instructions for known fields
        names = @namesFor(resource)
        fields[names.age_group]?.instructions = "Select the age groups of the events you want to filter"
        fields[names.date]?.instructions = "Select the date range of the events you want to filter"
        fields[names.ethnicity]?.instructions = "Select the ethnicities of the events you want to filter"
        fields[names.gender]?.instructions = "Select the genders of the events you want to filter"
        fields[names.result]?.instructions = "Select the results of the events you want to filter"

        q.resolve(new FieldsCollection(fields, @namesFor(resource), settings.fieldsWhitelist?[resource]))

      q.promise
