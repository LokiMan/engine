GoTo = (
  storage, scenes, startScene, components, connections, logger, collection
)->
  {callSceneComponents, sceneToClient} = components

  onPlayer = (player)->
    path = [collection, player.id]

    if storage.has path
      sceneID = storage.get path
    else
      sceneID = startScene
      storage.set path, sceneID

    currentScene = scenes[sceneID]

    Object.defineProperty player, 'scene', get: -> currentScene

    player.goTo = (newSceneID)->
      toScene = scenes[newSceneID]

      if not toScene?
        logger.error "Scene doesn't exists: #{newSceneID}, uid: #{player.id}"
        return

      callSceneComponents player, 'leave', toScene

      fromScene = currentScene
      storage.set path, newSceneID
      currentScene = toScene

      callSceneComponents player, 'enter', fromScene

      connection = connections.get player
      if connection?
        sceneData = sceneToClient player, fromScene
        connection.send JSON.stringify ['updateScene', sceneData]

  {onPlayer}

module.exports = GoTo
