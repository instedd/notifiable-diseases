angular.module('ndApp')
  .service 'FieldsService', ->
    Fields = [
      {
        name: "age_group",
        label: "Age group",
        instructions: "Select the age groups of the events you want to filter",
        type: "enum",
        valid_values:
          options: [
            {value:  "0-10", label:  "0-10"},
            {value: "10-20", label: "10-20"},
            {value: "20-30", label: "20-30"},
            {value: "30-40", label: "30-40"},
            {value: "40-50", label: "40-50"},
            {value: "50-60", label: "50-60"},
            {value:   "60+", label:   "60+"},
          ]
      },
      {
        name: "date",
        label: "Date",
        instructions: "Select the date range of the events you want to filter"
        type: "date",
      },
      {
        name: "ethnicity",
        label: "Ethnicity",
        instructions: "Select the ethnicities of the events you want to filter"
        type: "enum",
        valid_values:
          options: [
            {value: "1002-5", label: "American Indian or Alaska Native"},
            {value: "2028-9", label: "Asian"},
            {value: "2054-5", label: "Black or African American"},
            {value: "2076-8", label: "Native Hawaiian or Other Pacific Islander"},
            {value: "2106-3", label: "White"},
            {value: "2135-2", label: "Hispanic"},
            {value: "2131-1", label: "Other Race"},
          ]
      },
      {
        name: "gender",
        label: "Gender",
        instructions: "Select the genders of the events you want to filter"
        type: "enum",
        valid_values:
          options: [
            {value: "female", label: "Female"},
            {value: "male", label: "Male"},
          ]
      },
      {
        name: "result",
        label: "Result",
        instructions: "Select the results of the events you want to filter"
        type: "result",
      }
    ]

    service =
      all: ->
        Fields

      allEnum: ->
        _.select service.all(), (field) ->
          field.type == "enum" || field.type == "result"

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
