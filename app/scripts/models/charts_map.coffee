angular.module('ndApp')
  .factory 'Map', (Cdx, FieldsService) ->
    class Map
      constructor: ->
        @kind = 'Map'

      @deserialize: (data) ->
        new Map

      isConfigurable: ->
        false

      # ?
      applyToQuery: (query) ->
        # console.log("applyToQuery: " + JSON.stringify(query))
        
      # ?
      getSeries: (report, data) ->
        # console.log("getSeries.report: " + JSON.stringify(report))
        # console.log("getSeries.data: " + JSON.stringify(data))
        
      # ?
      getCSV: (series) ->
        # rows = []
        # rows.push ["Age", "Male", "Female"]
        # for serie in series
        #   rows.push [serie.age, serie.male, serie.female]
        # rows