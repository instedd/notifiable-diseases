use_local_storage = false

module = angular.module('ndApp')

if use_local_storage
  module.service 'ReportsService', (localStorageService, Report) ->
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

else
  module.service 'ReportsService', (KeyValueStore, $q, rfc4122, Report) ->
    reportsDescriptionsKey = 'reportsDescriptions'

    qReportsDescriptions = $q.defer()
    reportsDescriptions = []
    reportsDescriptionsVersion = null

    KeyValueStore.get(reportsDescriptionsKey).success (data) ->
      if data.found
        reportsDescriptionsVersion = data.version
        for report in JSON.parse(data.value)
          reportsDescriptions.push Report.deserialize(report)

      qReportsDescriptions.resolve(reportsDescriptions)

    reportKey = (id) ->
      "report_#{id}"

    saveReportsDescriptions = ->
      q = $q.defer()

      KeyValueStore.put(reportsDescriptionsKey, JSON.stringify(reportsDescriptions), reportsDescriptionsVersion).success (data) ->
        reportsDescriptionsVersion = data.version
        q.resolve(data)

      q.promise

    service =
      reportsDescriptions: ->
        qReportsDescriptions.promise

      create: (report) ->
        q = $q.defer()

        report.id = rfc4122.v4()
        reportsDescriptions.push id: report.id, name: report.name

        desc = saveReportsDescriptions()
        desc.then ->
          service.save(report)

      findById: (id) ->
        q = $q.defer()

        KeyValueStore.get(reportKey(id)).success (data) ->
          if data.found
            report = Report.deserialize(JSON.parse(data.value))
            report.version = data.version
          else
            report = null
          q.resolve(report)

        q.promise

      delete: (report) ->
        q = $q.defer()

        for desc, index in reportsDescriptions
          if desc.id == report.id
            reportsDescriptions.splice(index, 1)

            saveReportsDescriptions().then ->
              KeyValueStore.delete(reportKey(report.id)).success ->
                q.resolve(reportsDescriptions)
            break

        q.promise

      save: (report) ->
        q = $q.defer()

        KeyValueStore.put(reportKey(report.id), JSON.stringify(report), report.version).success (data) ->
          report.version = data.version
          q.resolve(report)

        q.promise
