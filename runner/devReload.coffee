DevServer = require '../dev-server/index'
CoreStarter = require './coreStarter'

DevReload = ->
  {
    engineDir, entryPort, gameFile, corePort, requiresSource
    cron, server, webSocketServer, router, hb, logger, config, startCore
    componentsConstructors, includes
  } = CoreStarter()

  devServer = DevServer engineDir, logger, {
    entryPort, gameFile, corePort, requiresSource, componentsConstructors
  }, includes, ->
    cron.clear()

    process.removeListener 'uncaughtException', logger.exception
    server.removeListener 'request', router

    webSocketServer.removeAllListeners 'connection'
    hb.clear()

    {
      requiresSource, components, players, router, hb, logger
      componentsConstructors, includes
    } = startCore()

    devServer.setComponentsConstructors componentsConstructors
    devServer.setIncludes includes

    prevCall = components.callSceneComponents
    components.callSceneComponents = (player, functionName, args...)->
      # При перезапуске сервера подключенные сокеты не разрываются и при
      # последующем обновлении браузера будет происходить выход игроков
      # в оффлайн. Эта проверка игнорирует игроков из предыдушего запуска.
      if functionName is 'offline' and player isnt players.getByUID player.id
        return

      prevCall.call components, player, functionName, args...

    requiresSource

  if config.build?
    for name, entry of config.build
      devServer.add name, entry

module.exports = DevReload
