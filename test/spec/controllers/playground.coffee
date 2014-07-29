'use strict'

describe 'Controller: PlaygroundCtrl', ->

  # load the controller's module
  beforeEach module 'ndApp'

  MainCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    MainCtrl = $controller 'PlaygroundCtrl', {
      $scope: scope
    }

  it 'should attach an empty list of records to the scope', ->
    expect(scope.data.length).toBe 0
