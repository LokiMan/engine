path = require 'path'
fs = require 'fs'
http = require 'http'
ws = require 'ws'

rand = require '../common/rand'
dates = require '../common/dates'
Timers = require '../common/timers'

ConnectWebSocket = require '../rpc/server/websocket'
heartbeat = require '../rpc/server/heartbeat'
ConnectPolling = require '../rpc/server/polling'
PlayerConnection = require '../rpc/server/playerConnection'
PackFor = require '../rpc/lib/packFor'

loadGame = require '../game/server/loadGame'
GamePageFactory = require '../game/server/gamePage'
EngineFactory = require '../game/server/engineParts'
constructGame = require '../game/server/constructGame'
GoTo = require '../game/server/goTo'
PlayerFactory = require '../game/server/playerFactory'
Components = require '../game/server/components'

Router = require '../router/router'

UIDGenerator = require './utils/uidGenerator'
parseCookie = require './utils/parseCookie'
Logger = require './utils/logger'
initStorage = require './utils/initStorage'
Cron = require './utils/cron'

PLAYER_SCENES_COLLECTION_NAME = 'playerScene'

CoreStarter = (getGamePagesHash = (-> null))->
  {env} = process
  {NODE_ENV = 'local'} = env

  engineDir = path.join __dirname, '../'
  gameDir = process.cwd()

  srcDir = path.join gameDir, './src/'

  gameFile = if fs.existsSync("#{srcDir}game.coffee") then 'game' else 'main'

  env.NODE_PATH = "#{engineDir}#{path.delimiter}#{env.NODE_PATH}"
  require('module').Module._initPaths()

  server = http.createServer()
  webSocketServer = new ws.Server {server}

  timers = Timers global
  {wait, interval} = timers

  storage = null
  cron = Cron()

  startCore = ->
    auth = null
    players = null

    obtainPlayer = (req)->
      cookie = req.cookie = parseCookie req.headers.cookie
      if (uid = auth.getUid cookie)? then players.getByUID(uid) else null

    router = Router 32000, obtainPlayer

    logger = Logger()

    config =
      title: 'no_title'
      startScene: 'start'

    {
      gameComponents, scenes, componentsConstructors, requiresSource
    } = loadGame {srcDir, gameFile, load: require, env: NODE_ENV, config}

    if not storage? or config.gameData?
      storage = initStorage gameDir, config.gameData, NODE_ENV

      if not storage.has [PLAYER_SCENES_COLLECTION_NAME]
        storage.set [PLAYER_SCENES_COLLECTION_NAME], {}

    {
      GamePage, refreshGamePagesHash
    } = GamePageFactory config.title, config.body, config.container,
      getGamePagesHash

    playersCollection = storage.getRef [PLAYER_SCENES_COLLECTION_NAME]
    auth = UIDGenerator playersCollection, router, GamePage, dates,
      rand.RandomString, config.uidGenerator

    connections = new Map

    common = {rand, dates, timers}

    Engine = EngineFactory {
      components: gameComponents, scenes
      storage, router, cron, logger, auth, connections
      PackFor, GamePage, common
    }

    constructGame gameComponents, scenes, componentsConstructors, Engine

    components = Components gameComponents, logger
    goTo = GoTo storage, scenes, config.startScene, components, connections,
      logger, PLAYER_SCENES_COLLECTION_NAME
    players = PlayerFactory gameComponents, goTo

    connectPlayer = PlayerConnection obtainPlayer, components, connections, wait

    ConnectWebSocket webSocketServer, connectPlayer
    ConnectPolling router, connectPlayer, wait, rand.RandomString

    hb = heartbeat webSocketServer, interval

    router.head['/'] = (req, res)-> # Server ready to get connections
      res.end()

    server.on 'request', router

    process.on 'uncaughtException', logger.exception

    {
      webSocketServer, requiresSource, components, players, router, hb, logger
      connections, config, refreshGamePagesHash
    }

  {
    webSocketServer, requiresSource, router, hb, logger, connections, config
    refreshGamePagesHash
  } = startCore()

  gameName = (_ref = gameDir.split('/'))[_ref.length - 1]

  entryPort = config.port
  corePort = Number(entryPort) + 1

  server.listen corePort, 'localhost', ->
    logger.info "#{gameName} running at http://localhost:#{entryPort}/"

  reconnectAll = ->
    for connection from connections.values()
      connection.send 'reconnect'
      connection.close()
    connections.clear()

  {
    engineDir, gameDir, entryPort, gameFile, corePort, requiresSource
    cron, server, webSocketServer, router, hb, logger, config, reconnectAll
    refreshGamePagesHash
    startCore
  }

module.exports = CoreStarter
