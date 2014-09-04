'use strict'

angular.module('ndApp')
  .controller 'MainCtrl', ($scope, $http, $location, $log, $routeParams, ReportsService, FieldsService) ->
    ReportsService.reportsDescriptions().then (reportsDescriptions) ->
      if reportsDescriptions.length == 0
        $location.path "/reports/new"
      else
        $location.path "/reports/#{reportsDescriptions[0].id}"
