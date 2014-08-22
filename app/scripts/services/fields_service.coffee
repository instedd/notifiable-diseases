angular.module('ndApp')
  .service 'FieldsService', (Cdx, $q) ->
    Fields = null

    appendFlattenedLocations = (locations, all) ->
      locations = _.sortBy locations, (location) -> location.name.toLowerCase()
      for location in locations
        all.push location
        appendFlattenedLocations location.children, all
      all

    service =
      init: (context = {}) ->
        q = $q.defer()
        Cdx.fields(context).success (data) ->
          Fields = data

          service.find("age_group")?.instructions = "Select the age groups of the events you want to filter"
          service.find("date")?.instructions = "Select the date range of the events you want to filter"
          service.find("ethnicity")?.instructions = "Select the ethnicities of the events you want to filter"
          service.find("gender")?.instructions = "Select the genders of the events you want to filter"
          service.find("result")?.instructions = "Select the results of the events you want to filter"

          q.resolve()
        q.promise

      all: ->
        Fields

      allEnum: ->
        _.select service.all(), (field) -> field.type == "enum"

      find: (name) ->
        for field in Fields
          if field.name == name
            return field
        null

      typeFor: (name) ->
        service.find(name).type

      labelFor: (name) ->
        service.find(name).label

      instructionsFor: (name) ->
        service.find(name).instructions

      optionsFor: (name) ->
        service.find(name).valid_values.options

      optionLabelFor: (name, option) ->
        options = service.optionsFor(name)
        _.find(options, (o) -> o.value == option).label

      valuesFor: (field) ->
        _.map service.optionsFor(field), (option) -> option.value

      flattenedLocations: (name) ->
        roots = service.find(name).valid_values.locations
        appendFlattenedLocations roots, []
