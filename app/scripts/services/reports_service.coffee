angular.module('ndApp')
  .service 'ReportsService', (localStorageService, Report) ->
    reports = localStorageService.get("reports")
    if reports
      reports = _.map reports, (report) ->
        Report.deserialize(report)
    else
      reports = []

    reports: ->
      reports

    create: (report, callback) ->
      reports.push report
      report.id = reports.length
      callback(report)

    findById: (id) ->
      id = parseInt id
      for report in reports
        return report if report.id == id
      null

    save: ->
      localStorageService.add "reports", reports
