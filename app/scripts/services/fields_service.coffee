angular.module('ndApp')
  .service 'FieldsService', ->
    Options =
      gender:    [
                   {value: "female", label: "Female"},
                   {value: "male", label: "Male"},
                 ]
      ethnicity: [
                   {value: "1002-5", label: "American Indian or Alaska Native"},
                   {value: "2028-9", label: "Asian"},
                   {value: "2054-5", label: "Black or African American"},
                   {value: "2076-8", label: "Native Hawaiian or Other Pacific Islander"},
                   {value: "2106-3", label: "White"},
                   {value: "2131-1", label: "Other Race"},
                 ]

    optionsFor: (field) ->
      Options[field]

    valuesFor: (field) ->
      _.map Options[field], (option) -> option.value
