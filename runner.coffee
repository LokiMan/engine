path = require 'path'
fs = require 'fs'
http = require 'http'
ws = require 'ws'

heartbeat = require './rpc/server/heartbeat'
loadGame = require './game/server/loadGame'
GamePageFactory = require './game/server/gamePage'
EngineFactory = require './game/server/engineParts'
constructGame = require './game/server/constructGame'
GoTo = require './game/server/goTo'
PlayerFactory = require './game/server/playerFactory'
Router = require './router/router'
UIDGenerator = require './runner/uidGenerator'
parseCookie = require './runner/parseCookie'
Logger = require './runner/logger'

initStorage = require './runner/initStorage'
Connections = require './runner/connections'
Components = require './game/server/components'

Remote = require './rpc/lib/remote'

Cron = require './runner/cron'

gameDir = process.cwd()
gamePort = process.argv[2]
worldPort = Number(gamePort) + 1

packageJson = require path.join gameDir, './package.json'

{env} = process
{NODE_ENV = 'local'} = env
storage = initStorage gameDir, packageJson, NODE_ENV

gameFile = env['npm_package_main'] ? 'game'
startScene = env['npm_package_startScene'] ? 'start'

srcDir = path.join gameDir, './src/'

players = null
remotes = new Map

cron = Cron()
logger = Logger()

title = env['npm_package_title'] ? 'no_title'

playerScenesCollectionName = 'playerScene'

if not storage.has [playerScenesCollectionName]
  storage.set [playerScenesCollectionName], {}

server = http.createServer()

webSocketServer = new ws.Server {server}

server.listen worldPort, 'localhost', ->
  logger.info "#{title} running at http://localhost:#{gamePort}/"

engineDir = __dirname
env.NODE_PATH = "#{engineDir}#{path.delimiter}#{env.NODE_PATH}"
require('module').Module._initPaths()

startGame = (logger)->
  auth = null
  players = null

  obtainPlayer = (req)->
    cookie = req.cookie = parseCookie req.headers.cookie
    if (uid = auth.getUid cookie)? then players.getByUID(uid) else null

  router = Router env['npm_package_routerMaxPostLength'], obtainPlayer

  {
    gameComponents, scenes, componentsConstructors, requiresSource
  } = loadGame {
    srcDir, gameFile, components: packageJson.components, load: require
    env: NODE_ENV
  }

  {
    GamePage, refreshGamePagesHash
  } = GamePageFactory env['npm_package_title'], env['npm_package_body'],
    env['npm_package_container'], getGamePagesHash

  playersCollection = storage.getRef [playerScenesCollectionName]
  cookieName = env['npm_package_uidGenerator_cookieName']
  expires = Number env['npm_package_uidGenerator_expires']
  auth = UIDGenerator playersCollection, router, GamePage, cookieName, expires

  Engine = EngineFactory {
    components: gameComponents, scenes
    storage, router, cron, logger, auth, remotes
    packFor: Remote.packFor, GamePage
  }

  constructGame gameComponents, scenes, componentsConstructors, Engine

  components = Components gameComponents, logger
  goTo = GoTo storage, scenes, startScene, components, remotes, logger,
    playerScenesCollectionName
  players = PlayerFactory gameComponents, goTo

  connections = Connections webSocketServer, router, remotes, components,
    obtainPlayer

  router.get['/__core/refreshHash'] = (req, res)->
    refreshGamePagesHash()
    connections.reconnectAll()
    res.end 'ok.'

  hb = heartbeat webSocketServer

  server.on 'request', router

  {requiresSource, components, players, router, hb}

getGamePagesHash = ->
  if NODE_ENV in ['production', 'test']
    gameDir = process.cwd()
    pathHash = path.join gameDir, 'res/js/hash.json'
    hashJsonText = fs.readFileSync pathHash, {encoding: 'utf8'}
    JSON.parse hashJsonText
  else
    null

{requiresSource, router, hb} = startGame logger

process.on 'uncaughtException', logger.exception

if NODE_ENV isnt 'production' and NODE_ENV isnt 'test'
  DevServer = require './dev-server/index'

  devServer = DevServer engineDir, {
    gamePort, gameFile, worldPort, requiresSource
  }, ->
    cron.reStart()

    process.removeListener 'uncaughtException', logger.exception
    server.removeListener 'request', router

    webSocketServer.removeAllListeners 'connection'
    hb.clear()

    logger = Logger()
    process.on 'uncaughtException', logger.exception

    {
      requiresSource, components, players, router, hb
    } = startGame logger

    prevCall = components.callSceneComponents
    components.callSceneComponents = (player, functionName, args...)->
      # При перезапуске сервера подключенные сокеты не разрываются и при
      # последующем обновлении браузера будет происходить выход игроков
      # в оффлайн. Эта проверка игнорирует игроков из предыдушего запуска.
      if functionName is 'offline' and player isnt players.getByUID player.id
        return

      prevCall.call components, player, functionName, args...

    requiresSource

  if packageJson.build?
    for name, entry of packageJson.build
      devServer.add name, entry
