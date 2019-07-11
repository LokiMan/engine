EngineParts = (
  {components, scenes, storage, router, cron, logger, auth, remotes, packFor}
)-> (name)->
  {
    components
    scenes
    storage
    router
    cron
    logger
    auth

    remote: (player, command...)->
      remotes.get(player)?.callFor name, command

    broadcast: (players, command...)->
      message = packFor name, command
      for player in players
        remotes.get(player)?.raw message

    broadcastOnline: (command...)->
      message = packFor name, command
      for remote from remotes.values()
        remote.raw message
  }

module.exports = EngineParts
