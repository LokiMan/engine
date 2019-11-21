EngineParts = ({
  components, scenes, storage, router, cron, logger, auth, connections, PackFor
  GamePage
})-> (componentName)->
  packFor = PackFor componentName

  remote = (player, command...)->
    connections.get(player)?.send packFor command

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

    remote

    broadcast: (players, command...)->
      message = packFor command
      for player from players
        connections.get(player)?.send message

    broadcastOnline: (command...)->
      message = packFor command
      for connection from connections.values()
        connection.send message

    deSync: (player, args...)->
      msg = "deSync(#{player.id}, #{player.scene.id}.#{componentName}):"
      logger.info msg, args...
      connections.get(player)?.send JSON.stringify ['reSync']
  }

module.exports = EngineParts
