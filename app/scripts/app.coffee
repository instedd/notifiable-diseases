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
  .factory "HttpAuthInterceptor", ($q, settings) ->
    response: (response) ->
      response
    responseError: (rejection) ->
      if rejection.status == 401
        if window.parent != window
          window.parent.postMessage 'reload-on-auth-failed', (settings.parentURL || '*')
      $q.reject(rejection)

  .config ($httpProvider) ->
    $httpProvider.defaults.headers.common['X-Requested-With'] = 'AngularXMLHttpRequest'
    $httpProvider.interceptors.push 'HttpAuthInterceptor'

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

    if settings.parentURL

      # If we have a parentURL and we are not embedded in it, redirect to it
      if window.parent == window
        newLocation = "#{settings.parentURL}/#{window.location.hash}"
        window.location = newLocation
      else if settings.replaceParentURLHash
        # We change the parent window's hash to match this one, so when the user
        # refreshes it stays in the same page.
        $rootScope.$on '$routeChangeStart', ->
          window.parent.location.hash = window.location.hash

