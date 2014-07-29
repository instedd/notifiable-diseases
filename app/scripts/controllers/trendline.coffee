'use strict'

###*
 # @ngdoc function
 # @name ndApp.controller:TrendlineCtrl
 # @description
 # # TrendlineCtrl
 # Manages trendline test page
###

angular.module('ndApp').controller 'TrendlineCtrl', ($scope, $http, $log) ->

  $scope.data = []

  $scope.data = JSON.stringify([
    { created_at:"2011", count:494},
    { created_at:"2012", count:223},
    { created_at:"2013", count:80},
    { created_at:"2014", count:10}
  ], null, 2)

  format_for_chart = (result) =>
    _.map(result, (g) ->
      c: [
           { v: g.created_at },
           { 
             v: g.count,
             f: g.count + " events"
           }
         ]
    )

  chart_for = (data_str) =>
    {
      type: "AreaChart"
      cssStyle: "height:400px; width:700px;"
      data:
        cols: [
          { id: "year",  label: "Year",   type: "string", p: {} },
          { id: "count", label: "Events", type: "number", p: {} }
        ]
        rows: format_for_chart(JSON.parse(data_str))
      options:
        title: "Event count by year"
        isStacked: "true"
        fill: 20
        displayExactValues: true
        vAxis:
          title: "Sales unit"
          gridlines:
            count: 6
        hAxis:
          title: "Date"
      formatters: {}
      displayed: true
    }

  $scope.chart = chart_for($scope.data)

  $scope.doUpdate = () =>
    $scope.chart = chart_for($scope.data)