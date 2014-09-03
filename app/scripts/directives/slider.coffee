angular.module('ndApp')
  .directive 'ndSlider', (debounce) ->
    {
      restrict: 'E'
      scope:
        min: '='
        max: '='
        model: '='
      template: '<div class="nd-slider-widget"></div>',
      link: (scope, element, attrs) ->
        slider_container = element[0].children[0]

        if scope.model
          value_0 = scope.model.min
          value_1 = scope.model.max
        else
          value_0 = scope.min + (scope.max - scope.min) / 3
          value_1 = scope.min + 2 * (scope.max - scope.min) / 3

        $(slider_container).noUiSlider(
          start: [ value_0, value_1 ]
          range:
            'min': [ scope.min ]
            'max': [ scope.max ]
        )

        # debounce to prevent update on first click on control
        $(slider_container).on(
          change: debounce(((event,values)->
            scope.model.min = Math.floor(values[0])
            scope.model.max = Math.floor(values[1])
            scope.$apply('model')
          ), 100)
        )
    }