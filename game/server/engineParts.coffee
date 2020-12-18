EngineParts = ({
  components, scenes, storage, router, cron, logger, auth, connections, PackFor
  GamePage, common
})-> (componentName)->
  packForComponent = PackFor componentName

  remote = (player, command...)->
    connections.get(player)?.send packForComponent command

  {
    components...
    components
    scenes
    storage
    router
    cron
    logger
    auth
    GamePage
    common

    remote

    broadcast: (players, command...)->
      message = packForComponent command
      for player from players
        connections.get(player)?.send message
      return

    broadcastExcept: (players, exceptPlayer, command...)->
      message = packForComponent command
      for player from players when player isnt exceptPlayer
        connections.get(player)?.send message
      return

    broadcastOnline: (command...)->
      message = packForComponent command
      for connection from connections.values()
        connection.send message
      return

    deSync: (player, args...)->
      msg = "deSync(#{player.id}, #{player.scene.id}.#{componentName}):"
      logger.info msg, args...
      connections.get(player)?.send JSON.stringify ['reSync']
  }

module.exports = EngineParts
