class @Report
  constructor: (@name, @description) ->
    @filters = []
    @query = '{"group_by": "year(created_at)"}'
