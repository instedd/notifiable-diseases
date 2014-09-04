'use strict'

###*
 # @ngdoc overview
 # @name ndApp
 # @description
 # # ndApp
 #
 # Main module of the application.
###
angular
  .module('ndApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap',
    'googlechart',
    'debounce',
    'LocalStorageModule',
    'checklist-model',
    'uuid',
    'xeditable',
    'ngCsv',
    'config',
    'daterangepicker',
    'ui.select2',
  ])
  .config ($routeProvider) ->
    # CODEREVIEW: Use resource-like routes to instantiate controller with report with requested id. Rename MainCtrl to ReportsCtrl, and ReportsCtrl to NewReportCtrl. Handle missing reports from here and not from main controller.
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/reports/new',
        templateUrl: 'views/reports/new.html'
        controller: 'NewReportCtrl'
      .when '/reports/:reportId',
        templateUrl: 'views/main.html'
        controller: 'ReportCtrl'
      .when '/playground',
        templateUrl: 'views/playground.html'
        controller: 'PlaygroundCtrl'
      .otherwise
        redirectTo: '/'
  .run (editableOptions) ->
    editableOptions.theme = 'bs3'
  .run ($rootScope, settings) ->
    $rootScope.settings = settings

    # If we have a parentURL and we are not embedded in it, redirect to it
    if settings.parentURL && window.parent == window
      newLocation = "#{settings.parentURL}/#{window.location.hash}"
      window.location = newLocation
