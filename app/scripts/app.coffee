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
    'ngTouch'
  ])
  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'views/main.html'
        controller: 'MainCtrl'
      .when '/playground',
        templateUrl: 'views/playground.html'
        controller: 'PlaygroundCtrl'
      .otherwise
        redirectTo: '/'

