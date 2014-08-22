angular.module('ndApp').service 'RemoteReportsService', (KeyValueStore, $q, rfc4122, Report, settings) ->
  return if settings.useLocalStorage

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

    # This returns a JSON-encoded report. You must then invoke
    # deserialize to get the deserialized version.
    #
    # You also have getAssay, which allows you to get a report's assay
    # without fully deserializing it into an object.
    findById: (id) ->
      q = $q.defer()

      KeyValueStore.get(reportKey(id)).success (data) ->
        if data.found
          report = data
        else
          report = null
        q.resolve(report)

      q.promise

    getAssay: (data) ->
      JSON.parse(data.value).assay

    deserialize: (data) ->
      report = Report.deserialize(JSON.parse(data.value))
      report.version = data.version
      report

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

      # When saving a report we must update the corresponding
      # report description if the name changed.
      for reportDescription in reportsDescriptions
        if reportDescription.id == report.id && reportDescription.name != report.name
          reportDescription.name = report.name
          saveReportsDescriptions()
          break

      KeyValueStore.put(reportKey(report.id), JSON.stringify(report), report.version).success (data) ->
        report.version = data.version
        q.resolve(report)

      q.promise
