angular.module('ndApp').service 'LocalReportsService', (localStorageService, Report, settings) ->
  return unless settings.useLocalStorage

  reports = localStorageService.get("reports")
  if reports
    reports = _.map reports, (report) ->
      Report.deserialize(report)
  else
    reports = []

  save = ->
    localStorageService.add "reports", reports

  service =
    reportsDescriptions: ->
      then: (callback) ->
        descs = _.map reports, (report) ->
          desc =
            id: report.id
            name: report.name
        callback(descs)

    create: (report) ->
      reports.push report
      report.id = reports.length
      save()
      then: (callback)->
        callback()

    delete: (report) ->
      index = _.indexOf reports, report
      reports.splice(index, 1)
      save()
      then: (callback) ->
        service.reportsDescriptions().then (descs) ->
          callback(descs)

    save: (report) ->
      save()

    findById: (id) ->
      then: (callback) ->
        id = parseInt id
        for report in reports
          if report.id == id
            callback(report)
            return
        callback(null)
