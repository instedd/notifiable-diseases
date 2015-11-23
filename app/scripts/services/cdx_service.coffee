angular.module('ndApp')
  .service 'Cdx', ($http, $q, settings) ->
    maxQueueSize = 50
    queryDebounceMillis = 500

    queues = _.zipObject(settings.resources, _.times(settings.resources.length, (() -> [])))

    runQueries =
      _.debounce () ->
        _.forEach queues, (queue, resource) ->
          queries = _.pluck(queue, 'q')
          deferreds = _.pluck(queue, 'd')
          queue.length = 0

          $http.post("#{settings.api}/#{resource}/multi", queries: queries)
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
        resource = query.resource
        delete query.resource
        if not _.includes(settings.resources, resource)
          throw "Invalid resource: #{resource}"

        if settings.multiQueriesEnabled
          deferred = httpLikeDeferred()
          queues[resource].push({q: query, d: deferred})
          runQueries()
          deferred.promise
        else
          $http.post "#{settings.api}/#{resource}", query

      fields: (resource, context = {}) ->
        if not _.includes(settings.resources, resource)
          throw "Invalid resource: #{resource}"
        $http.get "#{settings.api}/#{resource}/schema?#{$.param context}"
