angular.module('ndApp')
  .service 'FieldsService', (Cdx, $q) ->
    Fields = null

    appendFlattenedLocations = (locations, all) ->
      locations = _.sortBy locations, (location) -> location.name.toLowerCase()
      for location in locations
        all.push location
        appendFlattenedLocations location.children, all
      all

    findLocationIn = (locations, id) ->
      for location in locations
        if location.id.toString() == id
          return location

        match = findLocationIn location.children, id
        return match if match

      null

    service =
      init: (context = {}) ->
        q = $q.defer()
        Cdx.fields(context).success (data) ->
          Fields = data

          # Keep only positive results
          resultField = _.find Fields, (field) -> field.name == "result"
          if resultField
            resultField.valid_values.options = _.select resultField.valid_values.options, (option) -> option.kind == "positive"

          service.find("age_group")?.instructions = "Select the age groups of the events you want to filter"
          service.find("date")?.instructions = "Select the date range of the events you want to filter"
          service.find("ethnicity")?.instructions = "Select the ethnicities of the events you want to filter"
          service.find("gender")?.instructions = "Select the genders of the events you want to filter"
          service.find("result")?.instructions = "Select the results of the events you want to filter"

          # For those fields that are of type location we build a map
          # of locationId -> location for faster access.
          for field in Fields
            if field.type == "location"
              field.byId = {}

              flattenedLocations = service.flattenedLocations(field.name)
              for location in flattenedLocations
                field.byId[location.id] = location

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

      locationFor: (name, id) ->
        id = id.toString()
        service.find(name).byId[id]

      locationLabelFor: (name, id) ->
        service.locationFor(name, id).name

      getParentLocations: (name, id) ->
        id = id.toString()

        parentLocations = []
        while true
          parentLocation = service.locationFor(name, id)
          if parentLocation
            parentLocations.push parentLocation
            id = parentLocation.parent_id
            break unless id
          else
            break
        parentLocations.shift()
        # parentLocations.reverse()
        parentLocations

      getFullLocationPath: (name, location) ->
        if location.parent_id && (parent = service.locationFor(name, location.parent_id))
          "#{location.name}, #{service.getFullLocationPath(name, parent)}"
        else
          location.name

      dateResolution: ->
        resolution = service.find("date")?.valid_values?.resolution
        resolution ?= "day"
        resolution

      datePeriods: ->
        resolution = service.dateResolution()

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
