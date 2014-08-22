angular.module('ndApp')
  .service 'FiltersService', (EnumFilter, DateFilter, FieldsService) ->
    service =
      create: (name) ->
        klass = service.findClass(name)
        new klass(name)

      deserialize: (data) ->
        service.findClass(data.name).deserialize(data)

      findClass: (name) ->
        field = FieldsService.find(name)
        switch field.type
          when "enum"
            EnumFilter
          when "date"
            DateFilter
          else
            throw "Unknown field type: #{field.type}"
