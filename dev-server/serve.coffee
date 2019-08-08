path = require 'path'
http = require 'http'

st = require 'st'
httpProxy = require 'http-proxy'

Build = require '../runner/build'
Run = require '../runner/run'

Serve = ->
  process.env.NODE_ENV ?= 'production'

  Build()
  {entryPort, corePort} = Run()

  gameDir = process.cwd()

  stOptions =
    path: path.join gameDir, './res'
    url: '/res'
    index: false
    passthrough: false
    cache:
      content:
        max: 1024 * 1024 * 64
        maxAge: 1000 * 31536000
        cacheControl: 'public, max-age=31536000'

  mount = st stOptions

  proxy = httpProxy.createProxyServer {target: "http://localhost:#{corePort}"}

  proxy.on 'error', (err, req, res)->
    res.end err.toString()

  onRequest = (req, res)->
    mount req, res, ->
      proxy.web req, res

  server = http.createServer onRequest

  server.on 'upgrade', (req, socket, head)->
    if req.url is '/'
      proxy.ws req, socket, head

  server.listen entryPort

module.exports = Serve
