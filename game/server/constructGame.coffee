fs = require 'fs'

constructGame = (
  gameComponents, scenes, srcDir
  storage, remotes, packFor, router, cron, logger, auth
)->
  constructGameComponent = (name, value)->
    pathTo = "#{srcDir}#{name}"

    pathToServer = "#{pathTo}/server/#{name}"
    if fs.existsSync pathToServer + '.coffee'
      try
        componentConstructor = require pathToServer
        component = componentConstructor value, {
          components: gameComponents
          storage
          router
          cron
          logger
          auth

          remote: (player, command...)->
            remotes.get(player)?.callFor name, command

          broadcastOnline: (command...)->
            message = packFor name, command
            for remote from remotes.values()
              remote.raw message
        }
      catch error
        throw error
    else if fs.existsSync "#{pathTo}/client/#{name}.coffee"
      component = toClient: -> value
    else
      throw new Error "Game component '#{name}' not found."

    component.pathTo = pathTo

    return component

  for name, value of gameComponents
    gameComponents[name] = constructGameComponent name, value

  scenesComponents = {}

  constructSceneComponent = (name, value)->
    if not (componentConstructor = scenesComponents[name])?
      componentConstructor = loadSceneComponentConstructor name
      scenesComponents[name] = componentConstructor

    if componentConstructor.isClientOnly
      component = toClient: -> value
      isServerOnly = false
    else
      engineElements = {
        components: gameComponents
        scenes
        storage
        cron
        logger
        auth

        remote: (player, command...)->
          remotes.get(player)?.callFor name, command

        broadcast: (players, command...)->
          message = packFor name, command
          for player in players
            remotes.get(player)?.raw message
      }
      component = componentConstructor value, engineElements
      isServerOnly = componentConstructor.isServerOnly

    return {component, isServerOnly}

  loadSceneComponentConstructor = (name)->
    pathTo = "#{srcDir}#{name}"
    pathToServer = "#{pathTo}/server/#{name}"
    if fs.existsSync pathToServer + '.coffee'
      try
        componentConstructor = require pathToServer

        if not fs.existsSync "#{pathTo}/client/#{name}.coffee"
          componentConstructor.isServerOnly = true
      catch error
        throw error
    else if fs.existsSync "#{pathTo}/client/#{name}.coffee"
      componentConstructor = isClientOnly: true
    else
      throw new Error "Scene component '#{name}' not found."

    componentConstructor.pathTo = pathTo

    return componentConstructor

  for id, scene of scenes
    toClient = []

    for name, value of scene
      {component, isServerOnly} = constructSceneComponent name, value
      scene[name] = component
      if not isServerOnly
        toClient.push [name, component]

    scene.id = id
    scene.toClient = toClient

  return scenesComponents

module.exports = constructGame
