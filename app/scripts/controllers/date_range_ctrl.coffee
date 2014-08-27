'use strict'

angular.module('ndApp')
  .controller 'DateRangeCtrl', ($scope, FieldsService) ->
    sinceDate = moment($scope.filter.since)
    untilDate = moment($scope.filter.until)

    $scope.dateResolution = FieldsService.dateResolution()
    $scope.dateRange =
      startDate: sinceDate
      endDate: untilDate

    $scope.sinceYear = sinceDate.year()
    $scope.sinceWeekYear = sinceDate.isoWeekYear()
    $scope.sinceMonth = sinceDate.month() + 1
    $scope.sinceWeek = sinceDate.isoWeek()

    $scope.untilYear = untilDate.year()
    $scope.untilWeekYear = untilDate.isoWeekYear()
    $scope.untilMonth = untilDate.month() + 1
    $scope.untilWeek = untilDate.isoWeek()

    updateWeeksInSinceYear = (year) ->
      $scope.sinceWeeks = getWeeksAsObjects($scope.sinceWeekYear)

    updateWeeksInUntilYear = (year) ->
      $scope.untilWeeks = getWeeksAsObjects($scope.untilWeekYear)

    getWeeksAsObjects = (year) ->
      week = 1
      maxWeeks = getMaxWeeksInYear year

      weeks = []
      while week <= maxWeeks
        weeks.push value: week, label: moment().isoWeekYear(year).isoWeek(week).format("[W]WW")
        week += 1
      weeks

    getMaxWeeksInYear = (year) ->
      Math.max(
            moment(new Date(year, 11, 31)).isoWeek(),
            moment(new Date(year, 11, 31 - 7)).isoWeek()
            )

    $scope.years = []

    now = moment()

    year = 1970
    maxYear = now.year()

    while year <= maxYear
      $scope.years.push year
      year += 1

    $scope.months = []

    month = 1
    while month <= 12
      $scope.months.push value: month, label: moment().month(month - 1).format("MMM")
      month += 1

    updateFilterSinceDate = (newValue, oldValue) ->
      return if newValue == oldValue

      switch $scope.dateResolution
        when "week"
          $scope.filter.since = moment().isoWeekYear($scope.sinceWeekYear).isoWeek($scope.sinceWeek).format("YYYY-MM-DD")
        when "month"
          $scope.filter.since = moment().year($scope.sinceYear).month($scope.sinceMonth - 1).date(1).format("YYYY-MM-DD")
        when "year"
          $scope.filter.since = "#{$scope.sinceYear}-01-01"

    updateFilterUntilDate = (newValue, oldValue) ->
      return if newValue == oldValue

      switch $scope.dateResolution
        when "week"
          $scope.filter.until = moment().isoWeekYear($scope.untilWeekYear).isoWeek($scope.untilWeek).add(6, "days").format("YYYY-MM-DD")
        when "month"
          $scope.filter.until = moment().year($scope.untilYear).month($scope.untilMonth - 1).date(1).add(1, "months").add(-1, "days").format("YYYY-MM-DD")
        when "year"
          $scope.filter.until = "#{$scope.untilYear}-01-01"

    $scope.$watch 'dateRange', (newValue, oldValue) ->
      return if newValue == oldValue

      $scope.filter.since = moment($scope.dateRange.startDate).format("YYYY-MM-DD")
      $scope.filter.until = moment($scope.dateRange.endDate).format("YYYY-MM-DD")

    $scope.$watch 'sinceYear', updateFilterSinceDate
    $scope.$watch 'sinceWeekYear', updateFilterSinceDate
    $scope.$watch 'sinceMonth', updateFilterSinceDate
    $scope.$watch 'sinceWeek', updateFilterSinceDate

    $scope.$watch 'untilYear', updateFilterUntilDate
    $scope.$watch 'untilWeekYear', updateFilterUntilDate
    $scope.$watch 'untilMonth', updateFilterUntilDate
    $scope.$watch 'untilWeek', updateFilterUntilDate

    $scope.$watch 'sinceWeekYear', updateWeeksInSinceYear
    $scope.$watch 'untilWeekYear', updateWeeksInUntilYear
