angular.module('ndApp').service 'ReportsService', (LocalReportsService, RemoteReportsService, settings) ->
  if settings.useLocalStorage
    LocalReportsService
  else
    RemoteReportsService
