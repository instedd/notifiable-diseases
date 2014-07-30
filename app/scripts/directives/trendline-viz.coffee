angular.module('ndApp')
  .directive 'ndTrendlineViz', ($http) ->
    return {
      restrict: 'E'
      scope:
        report: '='
      templateUrl: 'views/charts/trendline-viz.html'
      link: (scope, element, attrs) ->
        scope.$watch '[report, grouping]', (-> updateChart(scope, $http)), true
    }

updateChart = (scope, $http) ->
  if scope.report
    query = { group_by : "#{scope.grouping}(created_at)" }
    for filter in scope.report.filters
      filter.applyTo(query)

    $http.post("/cdx/v1/events", query).success (data) ->
      scope.series = data