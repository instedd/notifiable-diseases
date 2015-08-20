angular.module('ndApp').service 'LocalReportsService', (localStorageService, settings, FiltersService, ChartsService) ->
  return unless settings.useLocalStorage

  # If the reports seralization format changes in a backwards incompatible way,
  # increment this number and old reports will be automatically discarded.
  CURRENT_VERSION = 1

  savedData = localStorageService.get("reports")
  if savedData && savedData.version == CURRENT_VERSION
    reports = savedData.reports
  else
    reports = []

  save = ->
    localStorageService.set("reports", {version: CURRENT_VERSION, reports: reports})

  findReportIndex = (id) ->
    _.findIndex reports, id: id

  nextId = ->
    _.max([0].concat(_.map(reports, 'id'))) + 1

  service =
    reportsDescriptions: ->
      then: (callback) ->
        descs = _.map reports, (report) ->
          desc =
            id: report.id
            name: report.name
        callback(descs)

    create: (report) ->
      report.id = nextId()
      reports.push report.toJSON()
      save()
      then: (callback)->
        callback()

    delete: (report) ->
      index = findReportIndex(report.id)
      return unless index >= 0

      reports.splice(index, 1)
      save()
      then: (callback) ->
        service.reportsDescriptions().then (descs) ->
          callback(descs)

    save: (report) ->
      index = findReportIndex(report.id)
      return unless index >= 0

      reports[index] = report.toJSON()
      save()
      then: (callback) ->
        callback()

    findById: (id) ->
      then: (callback) ->
        index = findReportIndex(parseInt id)
        if index >= 0
          callback reports[index]
        else
          callback null

    getContext: (data) ->
      context = {}
      context[data.mainField] = data.mainValue
      context

    deserialize: (data, fieldsCollection) ->
      data.filters = _.map data.filters, (filterData) -> FiltersService.deserialize(filterData, fieldsCollection)
      data.charts = _.map data.charts, (chartData) -> ChartsService.deserialize(chartData, fieldsCollection)
      report = new Report(fieldsCollection).initializeFrom(data)
      [report, null]

