angular.module('ndApp')
  .service 'FiltersService', () ->
    service =
      create: (field) ->
        klass = service.findClass(field.type)
        new klass(field)

      deserialize: (data, fieldsCollection) ->
        field = fieldsCollection.find(data.name)
        klass = service.findClass(field.type)
        new klass(field).initializeFrom(data)

      findClass: (type) ->
        switch type
          when "enum"
            Filters.EnumFilter
          when "date"
            Filters.DateFilter
          when "location"
            Filters.LocationFilter
          else
            throw "Unknown field type: #{type}"
