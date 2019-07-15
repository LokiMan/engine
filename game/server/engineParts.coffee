EngineParts = (
  {components, scenes, storage, router, cron, logger, auth, remotes, packFor}
)-> (componentName)->
  remote = (player, command...)->
    remotes.get(player)?.callFor componentName, command

  {
    components
    scenes
    storage
    router
    cron
    logger
    auth

    remote

    broadcast: (players, command...)->
      message = packFor componentName, command
      for player in players
        remotes.get(player)?.raw message

    broadcastOnline: (command...)->
      message = packFor componentName, command
      for rmt from remotes.values()
        rmt.raw message

    deSync: (player, args...)->
      msg = "deSync(#{player.id}, #{player.scene.id}.#{componentName}):"
      logger.info msg, args...
      remote player, '__world.reload'
  }

module.exports = EngineParts
