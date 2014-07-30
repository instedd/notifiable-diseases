angular.module('ndApp')
  .service 'ReportsService', ->
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
