dates = require '../common/dates'

pathToRegexp = require './pathToRegexp'

Router = (maxPostLength, obtainPlayer, parseBody = (require './parseBody'))->
  paths = {}
  regExpList = {GET: new Map, HEAD: new Map, POST: new Map}

  router = (req, res)->
    method = req.method
    url = req.url

    if (path = paths[url])? and (callback = path[method])?
      doCallbackByMethod method, callback, req, res
    else
      if (rPath = regExpList[method])?
        for {re, keys, callback} from rPath.values()
          if (m = url.match re)
            req.params ?= {}
            for key, i in keys
              req.params[key.name] = m[1 + i]

            return doCallbackByMethod method, callback, req, res

      res.statusCode = 404
      res.end 'Not found'

  doCallbackByMethod = (method, callback, req, res) ->
    switch method
      when 'GET', 'HEAD'
        setNoCache res
        doCallback callback, req, res

      when 'POST'
        parseBody req, maxPostLength, (err)->
          if err?
            res.statusCode = 400
            setNoCache res
            res.end err
          else
            doCallback callback, req, res

  setNoCache = (res)->
    res.setHeader 'Cache-Control', [
      'no-cache, no-store, must-revalidate, max-age=0'
      'post-check=0, pre-check=0'
    ]
    expires = (dates.fromValue(dates.now() - 1000 * 60 * 60 * 24)).toUTCString()
    res.setHeader 'Expires', expires
    res.setHeader 'Pragma', 'no-cache'
    res.setHeader 'Content-Type', 'text/html; charset=utf-8'

  doCallback = (callback, req, res)->
    if callback.length is 3
      player = obtainPlayer req
      callback req, res, player
    else
      callback req, res

  addMethod = (name)->
    upperName = name.toUpperCase()

    addPath = (path, callback)->
      url = paths[path]
      if not url?
        url = paths[path] = {}
      url[upperName] = callback

    Object.defineProperty router, name, get: ->
      return new Proxy {},
        set: (target, path, callback)->
          if path.includes ':'
            keys = []
            regexp = pathToRegexp path, keys
            rPathList = regExpList[upperName]
            rPathList.set regexp.toString(), {re: regexp, keys, callback}
          else
            addPath path, callback
            if path.length > 1
              if path[path.length - 1] is '/'
                addPath path[...-1], callback
              else
                addPath path + '/', callback
          return true

        get: (target, path)->
          paths[path]?[upperName]

  addMethod 'get'
  addMethod 'head'
  addMethod 'post'

  return router

module.exports = Router
