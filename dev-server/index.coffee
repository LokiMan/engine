path = require 'path'
http = require 'http'

st = require 'st'
httpProxy = require 'http-proxy'
chokidar = require 'chokidar'
ws = require 'ws'

Development = require './packer/development'

DevServer = (
  engineDir
  {entryPort, gameFile, corePort, requiresSource}
  reStartGame
)->
  gameDir = process.cwd()

  gameName = (_ref = gameDir.split('/'))[_ref.length - 1]

  srcDir = path.join gameDir, './src/'

  packers = {
    'game': Development engineDir, srcDir
  }

  needGameReload = false

  serverInError = ''

  setEntry = (source)->
    packers.game.setEntry 'game', srcDir, source

  setEntry requiresSource

  reloadGame = ->
    try
      setEntry reStartGame()
    catch e
      serverInError = e.stack
      return console.error e

    serverInError = ''

    needGameReload = false

  watcher = chokidar.watch srcDir, cwd: srcDir

  watcher.on 'change', (filePath)->
    ext = path.extname filePath
    if ext is '.coffee'
      found = false

      pathName = filePath[... -'.coffee'.length]

      if pathName is gameFile
        found = true
        needGameReload = true
        {clients} = packers.game
      else
        pathParts = pathName.split '/'

        length = pathParts.length
        return if length < 3 # at least name/type/name

        if ['server', 'lib'].some (p)-> pathParts.includes p
          componentPath = path.join srcDir, pathParts[0..(length - 3)].join('/')
          for name in Object.keys require.cache
            if name.startsWith componentPath
              delete require.cache[name]

          found = true
          needGameReload = true
          {clients} = wss

        if ['client', 'lib'].some (p)-> pathParts.includes p
          for name, packer of packers
            try
              if packer.reLoad pathName
                if name is 'game'
                  found = true
                  if not clients?
                    {clients} = packers.game
                else
                  for client in packer.clients
                    client.send 'reload'
            catch e
              for client in packer.clients
                client.send 'Ошибка при сборке клиента:\n' + e
              console.error e

      if found
        console.log '\x1Bc' # clear console

        console.log (new Date).toLocaleString(),
          ": #{gameName} reloaded ========================================="

        for client in clients
          client.send 'reload'

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

  proxyPort = corePort

  proxy = httpProxy.createProxyServer {target: "http://localhost:#{proxyPort}"}

  proxy.on 'error', (err, req, res)->
    res.end err.toString()

  onRequest = (req, res)->
    mount req, res, ->
      url = req.url
      if url[-3..-1] is '.js'
        if url[1..3] is 'js/'
          name = url['/js/'.length...-'.js'.length]
        else
          name = '../..' + url[0 ... -'.js'.length]

        if (packer = packers[name])?
          res.setHeader 'Content-Type', 'application/javascript'
          res.end packer.build()
        else
          for _, packer of packers
            if (file = packer.files.get(name))?
              res.setHeader 'Content-Type', 'application/javascript'
              return res.end file.compiled

          res.statusCode = 404
          res.end 'Not found'
      else
        if needGameReload
          reloadGame()

        if serverInError
          return showErrorPage res, serverInError

        proxy.web req, res

  server = http.createServer onRequest
  server.listen entryPort

  wss = new ws.Server {server, path: '/dev'}

  wss.on 'connection', (socket)->
    url = socket.upgradeReq.url
    packer = packers[url.substr 5]

    if packer?
      {clients} = packer
      clients.push socket

      socket.on 'close', ->
        clients.splice clients.indexOf(socket), 1

  server.on 'upgrade', (req, socket, head)->
    if req.url is '/'
      proxy.ws req, socket, head

  add = (name, entryFile)->
    packers[name] = Development engineDir, srcDir, {path: entryFile, name}

  showErrorPage = (res, error)->
    script = packers.game.getDevReloadJS()

    res.end """
<!DOCTYPE html>
<html>
  <head>
    <meta charset='utf-8'>
    <title>ERROR</title>
  <script>#{script}</script>
  </head>
  <body style='font-size: 15px'>
    <pre><font color="red">
      Ошибка при загрузке ядра сервера:<br/>
      #{error.replace /\n/g, '<br/>'}
    </font></pre>
  </body>
</html>
"""

  {add}

module.exports = DevServer
