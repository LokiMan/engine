UnpackAndRun = require '../lib/unpackAndRun'

TIME_TO_OFFLINE = 5000

PlayerConnection = (obtainPlayer, components, connections, wait)->
  onMessages = new Map()
  offlineTimers = new Map()

  (connection, req)->
    player = obtainPlayer req
    return connection.close() if not player?

    wasOnline = false

    if (offlineTimer = offlineTimers.get player)?
      offlineTimer.clear()
      offlineTimers.delete player
      wasOnline = true

    if (prevConnection = connections.get player)?
      prevConnection.onClose = (->)
      prevConnection.send 'disconnect'
      prevConnection.close()
      wasOnline = true

    connection.send JSON.stringify ['init', [
      components.gameComponentsToClient player
      components.sceneToClient player
    ]]

    connections.set player, connection

    if not wasOnline
      components.notify player, 'online'

    onMessage = onMessages.get player
    if not onMessage?
      onMessage = UnpackAndRun components.execute.bind null, player
      onMessages.set player, onMessage

    connection.onMessage = onMessage

    connection.onClose = ->
      connections.delete player

      offlineTimer = wait TIME_TO_OFFLINE, ->
        offlineTimers.delete player
        components.notify player, 'offline'

      offlineTimers.set player, offlineTimer

module.exports = PlayerConnection
