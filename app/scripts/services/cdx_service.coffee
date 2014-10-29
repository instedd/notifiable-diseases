angular.module('ndApp')
  .service 'Cdx', ($http, $q, settings) ->
    maxQueueSize = 50
    queryDebounceMillis = 500

    queue = []

    runQueries =
      _.debounce () ->
        queries = _.pluck(queue, 'q')
        deferreds = _.pluck(queue, 'd')
        queue = []

        $http.post("#{settings.api}/events/multi", queries: queries)
          .then (response) ->
              _.each _.zip(response.data, deferreds), ([data, deferred]) ->
                newresp = angular.copy(response)
                newresp.data = data
                deferred.resolve(newresp)
            , (info) ->
              _.each deferreds, (deferred) ->
                deferred.reject(info)
      , queryDebounceMillis, queue.length >= maxQueueSize

    # Regular promises don't have success/error methods,
    # so we add them to return promises that behave like $http promises
    httpLikeDeferred = () ->
      deferred = $q.defer()
      deferred.promise.success = (fn) ->
        deferred.promise.then((response) -> fn(response.data))
      deferred.promise.error = (fn) ->
        deferred.promise.then(null, fn)
      deferred

    service =
      events: (query) ->
        if settings.multiQueriesEnabled
          deferred = httpLikeDeferred()
          queue.push({q: query, d: deferred})
          runQueries()
          deferred.promise
        else
          $http.post "#{settings.api}/events", query

      fields: (context = {}) ->
        $http.get "#{settings.api}/events/schema?#{$.param context}"
