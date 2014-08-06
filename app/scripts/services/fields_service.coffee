angular.module('ndApp')
  .service 'FieldsService', ->
    Options =
      age_group: [
                   {value:  "0-10", label:  "0-10"},
                   {value: "10-20", label: "10-20"},
                   {value: "20-30", label: "20-30"},
                   {value: "30-40", label: "30-40"},
                   {value: "40-50", label: "40-50"},
                   {value: "50-60", label: "50-60"},
                   {value:   "60+", label:   "60+"},
                 ],
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
