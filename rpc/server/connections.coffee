timers = require '../../common/timers'
dates = require '../../common/dates'

Remote = require '../lib/remote'

ConnectionFactory = require './connection'
WebSocketState = require './states/webSocket'
SubscribeState = require './states/subscribe'

Connections = (webSocketServer, router, remotes, components, obtainPlayer)->
  Connection = ConnectionFactory timers.wait
  connections = new Map

  getConnection = (req)->
    if (player = obtainPlayer req)?
      connections.get player
    else
      null

  connectPlayer = (player, callback)->
    connection = connections.get player

    if not connection?
      connection = Connection ->
        connections.delete player
        remotes.delete player
        components.callSceneComponents player, 'offline'
        components.notifyGameComponents player, 'offline'

      connections.set player, connection

      remote = Remote connection, (cmd)->
        components.execute player, cmd

      remotes.set player, remote

      isNewConnection = true
    else
      if not connection.isClosed()
        connection.disconnect()
      remote = remotes.get player

      isNewConnection = false

    callback connection

    if isNewConnection
      components.notifyGameComponents player, 'online'
      components.callSceneComponents player, 'online'

    remote 'init', [
      components.gameComponentsToClient player
      components.sceneToClient player
    ]

  webSocketServer.on 'connection', (socket, req)->
    if (player = obtainPlayer req)?
      connectPlayer player, (connection)->
        WebSocketState connection, socket
        player.debugConnection = {
          socket
          remote: remotes.get player
          connected: dates.formatYMDHMS()
          userAgent: req.headers['user-agent']
        }
    else
      socket.close()

  subscribeState = SubscribeState timers.wait

  router.get['/connection/connect'] = (req, res)->
    if (player = obtainPlayer req)?
      connectPlayer player, (connection)->
        subscribeState connection, res
        player.debugConnection = {
          remote: remotes.get player
          connected: dates.formatYMDHMS()
          userAgent: req.headers['user-agent']
        }
    else
      res.end()

  router.get['/connection'] = (req, res)->
    if (connection = getConnection req)?
      subscribeState connection, res
      player = obtainPlayer req
      if player.debugConnection?
        player.debugConnection.remote = remotes.get player
        player.debugConnection.time = dates.formatYMDHMS()
        player.debugConnection.userAgent = req.headers['user-agent']
      else
        player.debugConnection = {
          remote: remotes.get player
          time: dates.formatYMDHMS()
          userAgent: req.headers['user-agent']
        }
    else
      res.end()

  router.post['/connection'] = (req, res)->
    if (message = req.body.message)? and (connection = getConnection req)?
      connection.onMessage message

    res.end()

  router.head['/'] = (req, res)->
    res.end()

  reconnectAll = ->
    for connection from connections.values()
      connection.reconnect()
    connections.clear()

  {reconnectAll}

module.exports = Connections
