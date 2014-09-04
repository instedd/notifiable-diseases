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
        @slider_container = $(element[0].children[0])

        if scope.model
          values = [scope.model.min, scope.model.max]
        else
          value_0 = scope.min + (scope.max - scope.min) / 3
          value_1 = scope.min + 2 * (scope.max - scope.min) / 3
          values = [value_0, value_1]

        @slider_container.noUiSlider(
          start: values
          behaviour: 'snap'
          range:
            min: [ scope.min ]
            max: [ scope.max ]
        )

        # debounce to prevent update on first click on control
        @slider_container.on(
          change: debounce(((event,values)->
            scope.model.min = Math.floor(values[0])
            scope.model.max = Math.floor(values[1])
            scope.$apply('model')
          ), 100)

          slide: (event, values) => update_tooltips(values)
        )

        update_tooltips(values)
    }

update_tooltips = (values) ->
  @slider_container.find('.noUi-handle-lower').html(tooltip_html(values[0]))
  @slider_container.find('.noUi-handle-upper').html(tooltip_html(values[1]))

tooltip_html = (value) ->
  "
    <div class='nd-slider-tooltip'>
    <strong>#{Math.floor(value)}</strong>
    </div>
  "