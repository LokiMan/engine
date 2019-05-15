timeStart = Date.now()

path = require 'path'
http = require 'http'
ws = require 'ws'

dates = require './common/dates'
{interval} = require './common/timers'

heartbeat = require './rpc/server/heartbeat'
loadGame = require './game/server/loadGame'
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
worldPort = gamePort + 1

packageJson = require path.join gameDir, './package.json'

{NODE_ENV} = process.env
storage = initStorage gameDir, packageJson, NODE_ENV

gameFile = process.env['npm_package_main'] ? 'game'
startScene = process.env['npm_package_startScene'] ? 'start'

srcDir = path.join gameDir, './src/'

players = null
remotes = new Map

cron = Cron()
logger = Logger()

title = process.env['npm_package_title'] ? 'no_title'

playerScenesCollectionName = 'playerScene'

if not storage.has [playerScenesCollectionName]
  storage.set [playerScenesCollectionName], {}

server = http.createServer()

webSocketServer = new ws.Server {server}

server.listen worldPort, 'localhost', ->
  logger.info "#{title} running at http://localhost:#{gamePort}/"

engineDir = __dirname
process.env.NODE_PATH = "#{engineDir}#{path.delimiter}#{process.env.NODE_PATH}"
require('module').Module._initPaths()

startGame = (logger)->
  auth = null
  players = null

  obtainPlayer = (req)->
    cookie = req.cookie = parseCookie req.headers.cookie
    if (uid = auth.getUid cookie)? then players.getByUID(uid) else null

  router = Router process.env['npm_package_routerMaxPostLength'], obtainPlayer

  playersCollection = storage.getRef [playerScenesCollectionName]
  cookieName = process.env['npm_package_uidGenerator_cookieName']
  expires = Number process.env['npm_package_uidGenerator_expires']
  auth = UIDGenerator playersCollection, router, title, cookieName, expires

  {gameComponents, scenes, includes} = loadGame dir: srcDir, file: gameFile

  if NODE_ENV in ['production', 'test']
    checkAndSkipDebug gameComponents
    for id, scene of scenes
      checkAndSkipDebug scene

  scenesComponents = constructGame gameComponents, scenes, srcDir,
    storage, remotes, Remote.packFor, router, cron, logger, auth

  components = Components gameComponents, logger
  goTo = GoTo storage, scenes, startScene, components, remotes, logger,
    playerScenesCollectionName
  players = PlayerFactory gameComponents, goTo

  Connections webSocketServer, router, remotes, components, obtainPlayer
  hb = heartbeat webSocketServer, interval

  server.on 'request', router

  {gameComponents, scenesComponents, includes, components, players, router, hb}

checkAndSkipDebug = (components)->
  for name in Object.keys(components)
    if name.startsWith '_debug_'
      delete components[name]

{gameComponents, scenesComponents, includes, router, hb} = startGame logger

process.on 'uncaughtException', logger.exception

if NODE_ENV isnt 'production' and NODE_ENV isnt 'test'
  DevServer = require './dev-server/index'

  devServer = DevServer engineDir, {
    gamePort, gameFile, worldPort, gameComponents, scenesComponents, includes
  }, ->
    cron.reStart()

    process.removeListener 'uncaughtException', logger.exception
    server.removeListener 'request', router

    webSocketServer.removeAllListeners 'connection'
    hb.clear()

    logger = Logger()
    process.on 'uncaughtException', logger.exception

    {
      gameComponents, scenesComponents, includes, components, players, router,
      hb
    } = startGame logger

    prevCall = components.callSceneComponents
    components.callSceneComponents = (player, functionName, args...)->
      # При перезапуске сервера подключенные сокеты не разрываются и при
      # последующем обновлении браузера будет происходить выход игроков
      # в оффлайн. Эта проверка игнорирует игроков из предыдушего запуска.
      if functionName is 'offline' and player isnt players.getByUID player.id
        return

      prevCall.call components, player, functionName, args...

    {gameComponents, scenesComponents, includes}

  if packageJson.build?
    for name, entry of packageJson.build
      devServer.add name, entry
